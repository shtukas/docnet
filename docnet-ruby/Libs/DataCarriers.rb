
# encoding: UTF-8

class DataCarriers

    # -------------------------------------------------------------
    # Issuing

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
            location = "#{Dir.home()}/Desktop/#{filename}"
            return nil if !File.exists?(location)
            return DataCarriers::issueAionPoint(description, location)
        end
    end

    # -------------------------------------------------------------
    # Operations

    # DataCarriers::objectIsDataCarrier(object): Boolean
    def self.objectIsDataCarrier(object)
        object["objectClass"] == "DataCarrier"
    end

    # DataCarriers::dataCarriers(): Array[DataCarrier]
    def self.dataCarriers()
        ObjectsManager::docNetObjects().select{|object| object["objectClass"] == "DataCarrier" }
    end

    # DataCarriers::toString(object): String
    def self.toString(object)
        raise "7b94f8fc-1d80-4d5c-a078-8b3625a4c4a6: #{object}" if object["objectClass"] != "DataCarrier"
        "[#{object["payloadType"]}] #{object["description"]}"
    end

    # DataCarriers::selectOneDataCarrierOrNull(): DataCarrier or null
    def self.selectOneDataCarrierOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("data carrier", DataCarriers::dataCarriers(), lambda{ |object| DataCarriers::toString(object) })
    end

    # DataCarriers::access(object)
    def self.access(object)

        raise "8bf1ae2c-5386-460b-9f6f-067e83910ea0: #{object}" if !DataCarriers::objectIsDataCarrier(object)

        if object["payloadType"] == "text" then
            text = DataManager::getBlobOrNull(object["payload"])
            puts text
            LucilleCore::pressEnterToContinue()
            return
        end

        if object["payloadType"] == "url" then
            url = DataManager::getBlobOrNull(object["payload"])
            puts url
            system("open '#{url}'")
            LucilleCore::pressEnterToContinue()
            return
        end

        if object["payloadType"] == "aion-point" then
            nhash = object["payload"]
            targetReconstructionFolderpath = "#{Dir.home()}/Desktop"
            AionCore::exportHashAtFolder(Elizabeth.new(), nhash, targetReconstructionFolderpath)
            puts "Export completed"
            LucilleCore::pressEnterToContinue()
            return
        end

        raise "40a20579-82f7-4b13-81ad-0db111b2c65e: #{object}"

    end

    # DataCarriers::edit(object): object
    def self.edit(object)

        raise "725ece68-e4d4-46a2-9449-c8be73b3de92: #{object}" if !DataCarriers::objectIsDataCarrier(object)

        if object["payloadType"] == "text" then
            nhash = object["payload"]
            text1 = DataManager::getBlobOrNull(nhash)
            text2 = LucilleCore::editTextSynchronously(text1)

            if text1 == text2 then
                return object
            end

            object["payload"] = DataManager::putBlob(text2)

            # We need to make some paperwork and return an updated object
            object["mutationId"] = SecureRandom.uuid
            object["timeVersion"] = Time.new.to_f
            DataManager::commitObjectoDisk(object)

            return object
        end

        if object["payloadType"] == "url" then
            nhash = object["payload"]
            text1 = DataManager::getBlobOrNull(nhash)
            text2 = LucilleCore::editTextSynchronously(text1)

            if text1 == text2 then
                return object
            end

            object["payload"] = DataManager::putBlob(text2)

            # We need to make some paperwork and return an updated object
            object["mutationId"] = SecureRandom.uuid
            object["timeVersion"] = Time.new.to_f
            DataManager::commitObjectoDisk(object)

            return object
        end

        if object["payloadType"] == "aion-point" then
            nhash = object["payload"]
            targetReconstructionFolderpath = "#{Dir.home()}/Desktop"
            AionCore::exportHashAtFolder(Elizabeth.new(), nhash, targetReconstructionFolderpath)
            puts "Export completed. Edit the file/directory and press enter for the upload process"
            LucilleCore::pressEnterToContinue()

            filename = LucilleCore::askQuestionAnswerAsString("filename on Desktop (empty to abort): ")
            return object if filename == ""
            location = "#{Dir.home()}/Desktop/#{filename}"
            return object if !File.exists?(location)

            nhash = AionCore::commitLocationReturnHash(Elizabeth.new(), location)
            object["payload"] = nhash

            # We need to make some paperwork and return an updated object
            object["mutationId"] = SecureRandom.uuid
            object["timeVersion"] = Time.new.to_f
            DataManager::commitObjectoDisk(object)

            return object
        end

        raise "74e79411-c613-401e-baf6-f7a140a162ea: #{object}"
    end

    # DataCarriers::landing(object)
    def self.landing(object)
        raise "6ca466b8-59d7-4811-9b9a-408390daa4d2: #{object}" if !DataCarriers::objectIsDataCarrier(object)

        loop {
            system("clear")
            puts DataCarriers::toString(object)

            puts "access | edit | json object".yellow

            command = LucilleCore::askQuestionAnswerAsString("> ")

            break if command == ""

            if Interpreting::match("access", command) then
                DataCarriers::access(object)
            end


            if Interpreting::match("edit", command) then
                DataCarriers::edit(object)
            end

            if Interpreting::match("json object", command) then
                puts JSON.pretty_generate(object)
                LucilleCore::pressEnterToContinue()
            end
        }
    end
end
