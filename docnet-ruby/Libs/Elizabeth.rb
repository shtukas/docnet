
# encoding: UTF-8

class Elizabeth

    def initialize()

    end

    def commitBlob(blob)
        DataManager::putBlob(blob)
    end

    def filepathToContentHash(filepath)
        DataManager::filepathToContentHash(filepath)
    end

    def readBlobErrorIfNotFound(nhash)
        blob = DataManager::getBlobOrNull(nhash)
        raise "[Elizabeth error: fc1dd1aa]" if blob.nil?
        blob
    end

    def datablobCheck(nhash)
        begin
            readBlobErrorIfNotFound(nhash)
            true
        rescue
            false
        end
    end
end