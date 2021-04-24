# encoding: UTF-8

class DataPortalUI

    # DataPortalUI::dataPortalFrontDocNet()
    def self.dataPortalFrontDocNet()
        system("clear")
        puts "DocNet (Multi-user Documentation Content Managment Network)"
        LucilleCore::pressEnterToContinue()

        loop {
            system("clear")

            puts "DocNet"

            ms = LCoreMenuItemsNX1.new()

            ##General Search is not valid in docnet
            #ms.item(
            #    "general search", 
            #    lambda { GeneralSearch::searchAndDive() }
            #)

            ms.item(
                "Read user documentation", 
                lambda { 
                    system("open 'https://github.com/shtukas/catalyst/blob/master/documentation/DocNet.md'")
                }
            )

            ms.item(
                "Network Interactive Search", 
                lambda { NSDT1Extended::interactiveSearchAndExplore() } # "NSDT1Extended" are called Network in the DocNet context.
            )

            ms.item(
                "node listing",
                lambda {
                    nodes = NSDataType1::objects()
                    nodes = NSDataType1::applyDateTimeOrderToType1s(nodes)
                    loop {
                        system("clear")
                        node = LucilleCore::selectEntityFromListOfEntitiesOrNull("node", nodes, lambda{|o| NSDataType1::toString(o) })
                        break if node.nil?
                        NSDataType1::landing(node)
                    }
                }
            )

            ms.item(
                "Make new node",
                lambda { 
                    ns1 = NSDataType1::issueNewNodeInteractivelyOrNull()
                    return if ns1.nil?
                    NSDataType1::landing(ns1)
                }
            )

            if Miscellaneous::isAlexandra() then
                ms.item(
                    "Merge two nodes",
                    lambda { 
                        puts "Merging two nodes"
                        puts "Selecting one after the other and then will merge"
                        node1 = NSDT1Extended::selectExistingType1InteractivelyOrNull()
                        return if node1.nil?
                        node2 = NSDT1Extended::selectExistingType1InteractivelyOrNull()
                        return if node2.nil?
                        if node1["uuid"] == node2["uuid"] then
                            puts "You have selected the same node twice. Aborting merge operation."
                            LucilleCore::pressEnterToContinue()
                            return
                        end

                        puts "merging:"
                        puts "    node1: #{NSDataType1::toString(node1)}"
                        puts "    node2: #{NSDataType1::toString(node2)}"

                        return if !LucilleCore::askQuestionAnswerAsBoolean("confirm merge : ")

                        # Moving all the node upstreams of node2 towards node1
                        NSDataType1::getUpstreamNodes(node2).each{|x|
                            Arrows::issueOrException(x, node1)
                        }
                        # Moving all the downstreams of node2 toward node1
                        NSDataType1::getDownstreamNodes(node2).each{|x|
                            Arrows::issueOrException(node1, x)
                        }
                        # Moving the datalines of node2 towards node1
                        NSDataType1::getNodeDatalinesInTimeOrder(node2).each{|x|
                            Arrows::issueOrException(node1, x)
                        }
                        NyxObjects::destroy(node2)
                    }
                )
            end

            if Miscellaneous::isAlexandra() then
                ms.item(
                    "dangerously edit a nyx object by uuid", 
                    lambda { 
                        uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
                        return if uuid == ""
                        object = NyxObjects::getOrNull(uuid)
                        return if object.nil?
                        object = Miscellaneous::editTextSynchronously(JSON.pretty_generate(object))
                        object = JSON.parse(object)
                        NyxObjects::destroy(object)
                        NyxObjects::put(object)
                    }
                )
            end

            if Miscellaneous::isAlexandra() then
                ms.item(
                    "Curation::session()", 
                    lambda { Curation::session() }
                )
            end

            ms.item(
                "Run network synchronization", 
                lambda { DataStoresOrchestration::fullSync() }
            )

            ms.item(
                "Show dataset statistics", 
                lambda { 
                    system("clear")
                    NyxPrimaryObjects::nyxNxSets().each{|setid|
                        puts "-> setid: #{setid}, count:#{NyxObjects::getSet(setid).size}"
                    }
                    LucilleCore::pressEnterToContinue()
                }
            )

            ms.item(
                "exit", 
                lambda { exit }
            )

            status = ms.prompt()
            # break if !status
        }
    end

    # DataPortalUI::dataPortalFront()
    def self.dataPortalFront()
        DataPortalUI::dataPortalFrontDocNet()
    end
end


