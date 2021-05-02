
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
end
