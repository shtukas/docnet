
# encoding: UTF-8

class ObjectsManager
      
    # ObjectsManager::collectDocNetObjects()
    def self.collectDocNetObjects()
        DataManager::enumerateObjectsFromDisk().reduce([]){|objects, object|
            isNewObjectOrNewerVersion = objects.none?{|o| o["objectId"] == object["objectId"] and o["timeVersion"] >= object["timeVersion"] } 
            if isNewObjectOrNewerVersion then
                objects << object
            end
            objects
        }
    end

    # ObjectsManager::fsck()
    def self.fsck()
        ObjectsManager::collectDocNetObjects().each{|object|
            ObjectsManager::fsckObject(object)
        }
        puts "All good!".green
    end

    # ObjectsManager::fsckReportObjectWithProblem(object, message)
    def self.fsckReportObjectWithProblem(object, message)
        puts JSON.pretty_generate(object)
        puts "[fsck fail] #{message}".red
        exit
    end

    # ObjectsManager::fsckObject(object)
    def self.fsckObject(object)
        # For the moment (13th May) we only cover the DataCarriers as they are the only objects we have in store.

        puts "[fsck] #{object["objectId"]}"

        if object["objectClass"] == "DataCarrier" and object["payloadType"] == "text" then
            text = DataManager::getBlobOrNull(object["payload"])
            if text.nil? then
                ObjectsManager::fsckReportObjectWithProblem(object, "Could not find payload datablob")
            end
        end

        if object["objectClass"] == "DataCarrier" and object["payloadType"] == "url" then
            text = DataManager::getBlobOrNull(object["payload"])
            if text.nil? then
                ObjectsManager::fsckReportObjectWithProblem(object, "Could not find payload datablob")
            end
        end

        if object["objectClass"] == "DataCarrier" and object["payloadType"] == "aion-point" then
            nhash = object["payload"]
            status = AionFsck::structureCheckAionHash(Elizabeth.new(), nhash)
            if !status then
                ObjectsManager::fsckReportObjectWithProblem(object, "Could not validate Aion Point")
            end
        end
    end
end
