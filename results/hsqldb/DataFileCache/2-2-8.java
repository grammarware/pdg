+	protected FileAccess fa;
	
+	protected String   dataFileName;
+   protected String   backupFileName;
+   protected Database database;

+ 	protected int     cacheFileScale;

+ 	protected int     cachedRowPadding;
+   protected int     initialFreePos;

+	protected RandomAccessInterface dataFile;
+   protected volatile long         fileFreePosition;

+ 	protected Cache                 cache;

+ 	Lock          writeLock = lock.writeLock();

    public void open(boolean readonly) {

        fileFreePosition = initialFreePos;

        database.logger.logInfoEvent("dataFileCache open start");

        try {
            boolean isNio = database.logger.propNioDataFile;
            int     fileType;

            if (database.logger.isStoredFileAccess()) {
                fileType = ScaledRAFile.DATA_FILE_STORED;
            } else if (database.isFilesInJar()) {
                fileType = ScaledRAFile.DATA_FILE_JAR;
            } else if (isNio) {
                fileType = ScaledRAFile.DATA_FILE_NIO;
            } else {
                fileType = ScaledRAFile.DATA_FILE_RAF;
            }

            if (readonly || database.isFilesInJar()) {
                dataFile = ScaledRAFile.newScaledRAFile(database,
                        dataFileName, readonly, fileType);

                dataFile.seek(FLAGS_POS);

                int flags = dataFile.readInt();

                is180 = !BitMap.isSet(flags, FLAG_190);

                if (BitMap.isSet(flags, FLAG_HX)) {
                    throw Error.error(ErrorCode.WRONG_DATABASE_FILE_VERSION);
                }

                dataFile.seek(LONG_FREE_POS_POS);

                fileFreePosition = dataFile.readLong();

                initBuffers();

                return;
            }

            long    freesize      = 0;
            boolean preexists     = fa.isStreamElement(dataFileName);
            boolean isIncremental = database.logger.propIncrementBackup;
            boolean isSaved       = false;

            if (preexists) {
                if (database.logger.isStoredFileAccess()) {
                    dataFile = ScaledRAFile.newScaledRAFile(database,
                            dataFileName, true, ScaledRAFile.DATA_FILE_STORED);
                } else {
                    dataFile = new ScaledRAFileSimple(database, dataFileName,
                                                      "r");
                }

                long    length       = dataFile.length();
                boolean wrongVersion = false;

                if (length > initialFreePos) {
                    dataFile.seek(FLAGS_POS);

                    int flags = dataFile.readInt();

                    isSaved       = BitMap.isSet(flags, FLAG_ISSAVED);
                    isIncremental = BitMap.isSet(flags, FLAG_ISSHADOWED);
                    is180         = !BitMap.isSet(flags, FLAG_190);

                    if (BitMap.isSet(flags, FLAG_HX)) {
                        wrongVersion = true;
                    }
                }

                dataFile.close();

                if (length > maxDataFileSize) {
                    throw Error.error(ErrorCode.WRONG_DATABASE_FILE_VERSION,
                                      "requires large database support");
                }

                if (wrongVersion) {
                    throw Error.error(ErrorCode.WRONG_DATABASE_FILE_VERSION);
                }
            }

            if (isSaved) {
                if (isIncremental) {
                    deleteBackup();
                } else {
                    boolean existsBackup = fa.isStreamElement(backupFileName);

                    if (!existsBackup) {
                        backupFile(false);
                    }
                }
            } else {
                if (isIncremental) {
                    preexists = restoreBackupIncremental();
                } else {
                    preexists = restoreBackup();
                }
            }

            dataFile = ScaledRAFile.newScaledRAFile(database, dataFileName,
                    readonly, fileType);

            if (preexists) {
                dataFile.seek(FLAGS_POS);

                int flags = dataFile.readInt();

                is180 = !BitMap.isSet(flags, FLAG_190);

                dataFile.seek(LONG_EMPTY_SIZE);

                freesize = dataFile.readLong();

                dataFile.seek(LONG_FREE_POS_POS);

                fileFreePosition      = dataFile.readLong();
                fileStartFreePosition = fileFreePosition;

                openShadowFile();
            } else {
                initNewFile();
            }

            initBuffers();

            fileModified  = false;
            cacheModified = false;
            freeBlocks =
                new DataFileBlockManager(database.logger.propMaxFreeBlocks,
                                         cacheFileScale, 0, freesize);

            database.logger.logInfoEvent("dataFileCache open end");
        } catch (Throwable t) {
            database.logger.logSevereEvent("dataFileCache open failed", t);
            close(false);

            throw Error.error(t, ErrorCode.FILE_IO_ERROR,
                              ErrorCode.M_DataFileCache_open, new Object[] {
                t.toString(), dataFileName
            });
        }
    }
	
	void initNewFile() throws IOException {

        fileFreePosition      = initialFreePos;
        fileStartFreePosition = initialFreePos;

        dataFile.seek(LONG_FREE_POS_POS);
        dataFile.writeLong(fileFreePosition);

        // set shadowed flag;
        int flags = 0;

        if (database.logger.propIncrementBackup) {
            flags = BitMap.set(flags, FLAG_ISSHADOWED);
        }

        flags = BitMap.set(flags, FLAG_ISSAVED);
        flags = BitMap.set(flags, FLAG_190);

        dataFile.seek(FLAGS_POS);
        dataFile.writeInt(flags);
        dataFile.synch();

        is180 = false;
    }

    void openShadowFile() {

        if (database.logger.propIncrementBackup
                && fileFreePosition != initialFreePos) {
            shadowFile = new RAShadowFile(database, dataFile, backupFileName,
                                          fileFreePosition, 1 << 14);
        }
    }
	
	private boolean restoreBackup() {

        // in case data file cannot be deleted, reset it
        deleteFile();

        try {
            FileAccess fa = database.logger.getFileAccess();

            if (fa.isStreamElement(backupFileName)) {
                FileArchiver.unarchive(backupFileName, dataFileName, fa,
                                       FileArchiver.COMPRESSION_ZIP);

                return true;
            }

            return false;
        } catch (Throwable t) {
            throw Error.error(t, ErrorCode.FILE_IO_ERROR,
                              ErrorCode.M_Message_Pair, new Object[] {
                t.toString(), backupFileName
            });
        }
    }

    /**
     * Restores in from an incremental backup
     */
    private boolean restoreBackupIncremental() {

        try {
            if (fa.isStreamElement(backupFileName)) {
                RAShadowFile.restoreFile(database, backupFileName,
                                         dataFileName);
                deleteBackup();

                return true;
            }

            return false;
        } catch (IOException e) {
            throw Error.error(ErrorCode.FILE_IO_ERROR, e);
        }
    }

    /**
     *  Parameter write indicates either an orderly close, or a fast close
     *  without backup.
     *
     *  When false, just closes the file.
     *
     *  When true, writes out all cached rows that have been modified and the
     *  free position pointer for the *.data file and then closes the file.
     */
    public void close(boolean write) {

        writeLock.lock();

        try {
            if (dataFile == null) {
                return;
            }

            if (write) {
                commitChanges();
            } else {
                if (shadowFile != null) {
                    shadowFile.close();

                    shadowFile = null;
                }
            }

            dataFile.close();
            database.logger.logDetailEvent("dataFileCache file close");

            dataFile = null;

            if (!write) {
                return;
            }

            boolean empty = fileFreePosition == initialFreePos;

            if (empty) {
                deleteFile();
                deleteBackup();
            }
        } catch (HsqlException e) {
            throw e;
        } catch (Throwable t) {
            database.logger.logSevereEvent("dataFileCache close failed", t);

            throw Error.error(t, ErrorCode.FILE_IO_ERROR,
                              ErrorCode.M_DataFileCache_close, new Object[] {
                t.toString(), dataFileName
            });
        } finally {
            writeLock.unlock();
        }
    }
	
	public void commitChanges() {

        writeLock.lock();

        try {
            if (cacheReadonly) {
                return;
            }

            database.logger.logInfoEvent("dataFileCache commit start");
            cache.saveAll();
            database.logger.logDetailEvent("dataFileCache save data");

            if (fileModified || freeBlocks.isModified()) {

                // set empty
                dataFile.seek(LONG_EMPTY_SIZE);
                dataFile.writeLong(freeBlocks.getLostBlocksSize());

                // set end
                dataFile.seek(LONG_FREE_POS_POS);
                dataFile.writeLong(fileFreePosition);

                // set saved flag;
                dataFile.seek(FLAGS_POS);

                int flags = dataFile.readInt();

                flags = BitMap.set(flags, FLAG_ISSAVED);

                dataFile.seek(FLAGS_POS);
                dataFile.writeInt(flags);
            }

            dataFile.synch();

            fileModified  = false;
            cacheModified = false;

            if (shadowFile != null) {
                shadowFile.close();

                shadowFile = null;
            }

            database.logger.logDetailEvent("dataFileCache commit end");
        } catch (Throwable t) {
            database.logger.logSevereEvent("dataFileCache commit failed", t);

            throw Error.error(t, ErrorCode.FILE_IO_ERROR,
                              ErrorCode.M_DataFileCache_close, new Object[] {
                t.toString(), dataFileName
            });
        } finally {
            writeLock.unlock();
        }
    }

    protected void initBuffers() {

        if (rowOut == null
                || rowOut.getOutputStream().getBuffer().length
                   > initIOBufferSize) {
            if (is180) {
                rowOut = new RowOutputBinary180(256, cachedRowPadding);
            } else {
                rowOut = new RowOutputBinaryEncode(database.logger.getCrypto(),
                                                   256, cachedRowPadding);
            }
        }

        if (rowIn == null || rowIn.getBuffer().length > initIOBufferSize) {
            if (is180) {
                rowIn = new RowInputBinary180(new byte[256]);
            } else {
                rowIn = new RowInputBinaryDecode(database.logger.getCrypto(),
                                                 new byte[256]);
            }
        }
    }
	
	void backupFile(boolean newFile) {

        writeLock.lock();

        try {
            if (database.logger.propIncrementBackup) {
                if (fa.isStreamElement(backupFileName)) {
                    deleteBackup();
                }

                return;
            }

            if (fa.isStreamElement(dataFileName)) {
                String filename = newFile
                                  ? dataFileName + Logger.newFileExtension
                                  : dataFileName;

                FileArchiver.archive(filename,
                                     backupFileName + Logger.newFileExtension,
                                     database.logger.getFileAccess(),
                                     FileArchiver.COMPRESSION_ZIP);
            }
        } catch (IOException e) {
            database.logger.logSevereEvent("backupFile failed", e);

            throw Error.error(ErrorCode.DATA_FILE_ERROR, e);
        } finally {
            writeLock.unlock();
        }
    }
	
	void deleteFile() {

        writeLock.lock();

        try {

            // first attemp to delete
            fa.removeElement(dataFileName);

            // OOo related code
            if (database.logger.isStoredFileAccess()) {
                return;
            }

            // OOo end
            if (fa.isStreamElement(dataFileName)) {
                this.database.logger.log.deleteOldDataFiles();
                fa.removeElement(dataFileName);

                if (fa.isStreamElement(dataFileName)) {
                    String discardName =
                        FileUtil.newDiscardFileName(dataFileName);

                    fa.renameElement(dataFileName, discardName);
                }
            }
        } finally {
            writeLock.unlock();
        }
    }

    void deleteBackup() {

        writeLock.lock();

        try {
            if (fa.isStreamElement(backupFileName)) {
                fa.removeElement(backupFileName);
            }
        } finally {
            writeLock.unlock();
        }
    }