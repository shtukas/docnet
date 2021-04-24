
=begin

The operator is an object that has meet the following signatures

    .commitBlob(blob: BinaryData) : Hash
    .filepathToContentHash(filepath) : Hash
    .readBlobErrorIfNotFound(nhash: Hash) : BinaryData
    .datablobCheck(nhash: Hash): Boolean

class Elizabeth

    def initialize()

    end

    def commitBlob(blob)
        nhash = "SHA256-#{Digest::SHA256.hexdigest(blob)}"
        KeyToStringOnDiskStore::set(nil, "SHA256-#{Digest::SHA256.hexdigest(blob)}", blob)
        nhash
    end

    def filepathToContentHash(filepath)
        "SHA256-#{Digest::SHA256.file(filepath).hexdigest}"
    end

    def readBlobErrorIfNotFound(nhash)
        blob = KeyToStringOnDiskStore::getOrNull(nil, nhash)
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

AionCore::commitLocationReturnHash(operator, location)
AionCore::exportHashAtFolder(operator, nhash, targetReconstructionFolderpath)

AionFsck::structureCheckAionHash(operator, nhash)

=end

# ------------------------------------------------------------------------

=begin

```
{
    "aionType" : "file"
    "name"     : String
    "size"     : Integer
    "hash"     : Hash
    "parts"    : Array[Hash] # Hashes of the binary blobs of the file
}

{
    "aionType" : "directory"
    "name"     : String
    "items" : Array[Hash] # Hashes of serialised Aion objects
}

{
    "aionType" : "indefinite"
    "name"     : String
}
```
=end

class AionCore

    # AionCore::macOSIconFilename(): String
    def self.macOSIconFilename()
        "Icon\r"
    end

    # AionCore::macOSDSStoreFilename(): String
    def self.macOSDSStoreFilename()
        '.DS_Store'
    end

    # AionCore::getAionObjectByHash(operator, nhash)
    def self.getAionObjectByHash(operator, nhash)
        aionObject = JSON.parse(operator.readBlobErrorIfNotFound(nhash))
        aionObject
    end

    # AionCore::locationsNamesInsideFolder(folderpath): Array[String]
    def self.locationsNamesInsideFolder(folderpath)
        Dir.entries(folderpath)
            .reject{|filename| [".", ".."].include?(filename) }
            .reject{|filename|  [AionCore::macOSIconFilename(), AionCore::macOSDSStoreFilename()].include?(filename) }
            .sort
    end

    # AionCore::locationPathsInsideFolder(folderpath): Array[String]
    def self.locationPathsInsideFolder(folderpath)
        AionCore::locationsNamesInsideFolder(folderpath).map{|filename| "#{folderpath}/#{filename}" }
    end

    # AionCore::commitFileReturnPartsHashs(operator, filepath)
    def self.commitFileReturnPartsHashs(operator, filepath)
        raise "[AionCore error: 8338057a]" if !File.exists?(filepath)
        raise "[AionCore error: e216e1f3]" if !File.file?(filepath)
        hashes = []
        partSizeInBytes = 1024*1024 # 1 MegaBytes
        f = File.open(filepath)
        while ( blob = f.read(partSizeInBytes) ) do
            hashes << operator.commitBlob(blob)
        end
        f.close()
        hashes
    end

    # AionCore::commitFileReturnAionObject(operator, filepath): AionObject(aionType:file)
    def self.commitFileReturnAionObject(operator, filepath)
        {
            "aionType" => "file",
            "name"     => File.basename(filepath),
            "size"     => File.size(filepath),
            "hash"     => operator.filepathToContentHash(filepath),
            "parts"    => AionCore::commitFileReturnPartsHashs(operator, filepath)
        }
    end

    # AionCore::commitDirectoryReturnAionObject(operator, folderpath)
    def self.commitDirectoryReturnAionObject(operator, folderpath)
        raise "[AionCore error: 8aa94546]" if !File.exists?(folderpath)
        raise "[AionCore error: ff9603a2]" if !File.directory?(folderpath)
        {
            "aionType" => "directory",
            "name"     => File.basename(folderpath),
            "items"    => AionCore::locationPathsInsideFolder(folderpath).map{|l| AionCore::commitLocationReturnHash(operator, l) }
        }
    end

    # AionCore::commitLocationReturnAionObject(operator, location)
    def self.commitLocationReturnAionObject(operator, location)
        if File.symlink?(location) then
            return {
                "aionType" => "indefinite",
                "name"     => File.basename(location)
            }
        end
        File.file?(location) ? AionCore::commitFileReturnAionObject(operator, location) : AionCore::commitDirectoryReturnAionObject(operator, location)
    end

    # AionCore::commitLocationReturnHash(operator, location)
    def self.commitLocationReturnHash(operator, location)
        aionObject = AionCore::commitLocationReturnAionObject(operator, location)
        blob = JSON.generate(aionObject)
        operator.commitBlob(blob)
    end

    # AionCore::exportAionObjectAtFolder(operator, aionObject, targetReconstructionFolderpath)
    def self.exportAionObjectAtFolder(operator, aionObject, targetReconstructionFolderpath)
        if aionObject["aionType"]=="file" then
            targetFilepath = "#{targetReconstructionFolderpath}/#{aionObject["name"]}"
            File.open(targetFilepath, "w"){|f|  
                aionObject["parts"].each{|nhash|
                    f.write(operator.readBlobErrorIfNotFound(nhash))
                }
            }
        end
        if aionObject["aionType"]=="directory" then
            targetSubFolderpath = "#{targetReconstructionFolderpath}/#{aionObject["name"]}"
            if !File.exists?(targetSubFolderpath) then
                FileUtils.mkpath(targetSubFolderpath)
            end
            aionObject["items"].each{|nhash|
                AionCore::exportHashAtFolder(operator, nhash, targetSubFolderpath)
            }
        end
        if aionObject["aionType"]=="indefinite" then
            targetFilepath = "#{targetReconstructionFolderpath}/#{aionObject["name"]}"
            FileUtils.touch(targetFilepath)
        end
    end

    # AionCore::exportHashAtFolder(operator, nhash, targetReconstructionFolderpath)
    def self.exportHashAtFolder(operator, nhash, targetReconstructionFolderpath)
        aionObject = AionCore::getAionObjectByHash(operator, nhash)
        AionCore::exportAionObjectAtFolder(operator, aionObject, targetReconstructionFolderpath)
    end

end

class AionFsck

    # AionFsck::aionObjectCheck(operator, aionObject)
    def self.aionObjectCheck(operator, aionObject)
        if aionObject["aionType"] == "file" then
            return aionObject["parts"].all?{|nhash| operator.datablobCheck(nhash) }
        end
        if aionObject["aionType"] == "directory" then
            return aionObject["items"].all?{|namedAionHash| AionFsck::structureCheckAionHash(operator, namedAionHash) }
        end
        if aionObject["aionType"] == "indefinite" then
            return true
        end
    end

    # AionFsck::structureCheckAionHash(operator, nhash)
    def self.structureCheckAionHash(operator, nhash)
        aionObject = nil
        begin
            aionObject = AionCore::getAionObjectByHash(operator, nhash)
        rescue Exception => e
            return false
        end
        AionFsck::aionObjectCheck(operator, aionObject)
    end
end


