
# encoding: UTF-8

class DataManager

    # DataManager::repositoryFolderPath()
    def self.repositoryFolderPath()
        "#{Dir.home}/.docnet/001-36b68946-26d9-4b49-85e3-7b9e2c7d9f84"
    end

    # DataManager::filepathToContentHash(filepath)
    def self.filepathToContentHash(filepath)
        "SHA256-#{Digest::SHA256.file(filepath).hexdigest}"
    end

    # DataManager::putBlob(blob)
    def self.putBlob(blob)
        nhash = "SHA256-#{Digest::SHA256.hexdigest(blob)}"
        folderpath = "#{DataManager::repositoryFolderPath()}/#{nhash[7, 2]}/#{nhash[9, 2]}"
        if !File.exists?(folderpath) then
            FileUtils.mkpath(folderpath)
        end
        filepath = "#{folderpath}/#{nhash}.data"
        File.open(filepath, "w"){|f| f.write(blob) }
        nhash
    end

    # DataManager::getBlobOrNull(nhash)
    def self.getBlobOrNull(nhash)
        folderpath = "#{DataManager::repositoryFolderPath()}/#{nhash[7, 2]}/#{nhash[9, 2]}"
        filepath = "#{folderpath}/#{nhash}.data"
        return nil if !File.exists?(filepath)
        IO.read(filepath)
    end

    # DataManager::commitObjectoDisk(object)
    def self.commitObjectoDisk(object)
        blob = JSON.generate(object)
        nhash = "SHA256-#{Digest::SHA256.hexdigest(blob)}"
        folderpath = "#{DataManager::repositoryFolderPath()}/#{nhash[7, 2]}/#{nhash[9, 2]}"
        if !File.exists?(folderpath) then
            FileUtils.mkpath(folderpath)
        end
        filepath = "#{folderpath}/#{nhash}.object"
        File.open(filepath, "w"){|f| f.write(blob) }
        nil
    end

    # DataManager::getGetObjectFromDiskOrNull(argument)
    def self.getGetObjectFromDiskOrNull(argument)
        # The data manager doesn't hve a notion of extracting a specific object from disk directly
        raise "c29e6620-4807-427b-b9e1-c25c98f37e1e"
    end

    # DataManager::enumerateObjectsFromDisk()
    def self.enumerateObjectsFromDisk()
        filter = lambda {|location|
            location[-7, 7] == ".object"
        }
        LucilleCore::enumeratorLocationsInFileHierarchyWithFilter(DataManager::repositoryFolderPath(), filter)
            .lazy
            .map{|filepath| JSON.parse(IO.read(filepath)) }
    end
end
