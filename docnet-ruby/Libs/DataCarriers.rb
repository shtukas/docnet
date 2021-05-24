
# encoding: UTF-8

class DataCarriers

    # DataCarriers::dataCarrierTypes(): Array[String]
    def self.dataCarrierTypes()
        ["text", "url", "aion-point"]
    end

    # DataCarriers::issueText(description, text): DataCarrier    
    def self.issueText(description, text)
        nhash = DataManager::putBlob(text)
        object = {
            "objectId"    => SecureRandom.uuid,
            "mutationId"  => SecureRandom.uuid,
            "timeVersion" => Time.new.to_f,
            "objectClass" => "DataCarrier",
            "payloadType" => "text",
            "description" => description,
            "payload"     => nhash
        }
        DataManager::commitObjectoDisk(object)
        object
    end

    # DataCarriers::issueUrl(description, url): DataCarrier   
    def self.issueUrl(description, url)
        nhash = DataManager::putBlob(url)
        object = {
            "objectId"    => SecureRandom.uuid,
            "mutationId"  => SecureRandom.uuid,
            "timeVersion" => Time.new.to_f,
            "objectClass" => "DataCarrier",
            "payloadType" => "url",
            "description" => description,
            "payload"     => nhash
        }
        DataManager::commitObjectoDisk(object)
        object
    end

    # DataCarriers::issueAionPoint(description, location): DataCarrier   
    def self.issueAionPoint(description, location)
        # Here we are going to raise an exception if the location doesn't exist
        # Because we expect the caller to have made that check
        nhash = AionCore::commitLocationReturnHash(Elizabeth.new(), location)
        object = {
            "objectId"    => SecureRandom.uuid,
            "mutationId"  => SecureRandom.uuid,
            "timeVersion" => Time.new.to_f,
            "objectClass" => "DataCarrier",
            "payloadType" => "aion-point",
            "description" => description,
            "payload"     => nhash
        }
        DataManager::commitObjectoDisk(object)
        object
    end

    # DataCarriers::interactivelyAskForDescriptionOrNull(): nil or String
    def self.interactivelyAskForDescriptionOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""
        description
    end

    # DataCarriers::interactivelyIssueNewDataCarrierOrNull(): DataCarrier  
    def self.interactivelyIssueNewDataCarrierOrNull()
        description = DataCarriers::interactivelyAskForDescriptionOrNull()
        return nil if description.nil?
        type = LucilleCore::selectEntityFromListOfEntitiesOrNull("DataCarrier type", DataCarriers::dataCarrierTypes())
        return nil if type.nil?
        if type == "text" then
            text = LucilleCore::editTextSynchronously("")
            return DataCarriers::issueText(description, text)
        end
        if type == "url" then
            url = LucilleCore::askQuestionAnswerAsString("url (empty to abort): ")
            return nil if url.nil?
            return DataCarriers::issueUrl(description, url)
        end
        if type == "aion-point" then
            filename = LucilleCore::askQuestionAnswerAsString("filename on Desktop (empty to abort): ")
            return nil if filename == ""
            location = "/Users/pascal/Desktop/#{filename}"
            return nil if !File.exists?(location)
            return DataCarriers::issueAionPoint(description, location)
        end
    end
end
