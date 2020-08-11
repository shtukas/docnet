
# encoding: UTF-8

class Waves

    # Waves::traceToRealInUnitInterval(trace)
    def self.traceToRealInUnitInterval(trace)
        ( '0.'+Digest::SHA1.hexdigest(trace).gsub(/[^\d]/, '') ).to_f
    end

    # Waves::traceToMetricShift(trace)
    def self.traceToMetricShift(trace)
        0.001*Waves::traceToRealInUnitInterval(trace)
    end

    # Waves::isLucille18()
    def self.isLucille18()
        ENV["COMPUTERLUCILLENAME"] == "Lucille18"
    end

    # Waves::makeScheduleObjectInteractivelyOrNull()
    def self.makeScheduleObjectInteractivelyOrNull()

        scheduleTypes = ['sticky', 'repeat']
        scheduleType = LucilleCore::selectEntityFromListOfEntitiesOrNull("schedule type: ", scheduleTypes, lambda{|entity| entity })

        schedule = nil
        if scheduleType=='sticky' then
            fromHour = LucilleCore::askQuestionAnswerAsString("From hour (integer): ").to_i
            schedule = {
                "uuid"      => SecureRandom.hex,
                "@"         => "sticky",
                "from-hour" => fromHour
            }
        end
        if scheduleType=='repeat' then

            repeat_types = ['every-n-hours','every-n-days','every-this-day-of-the-week','every-this-day-of-the-month']
            type = LucilleCore::selectEntityFromListOfEntities_EnsureChoice("repeat type: ", repeat_types, lambda{|entity| entity })

            if type=='every-n-hours' then
                print "period (in hours): "
                value = STDIN.gets().strip.to_f
            end
            if type=='every-n-days' then
                print "period (in days): "
                value = STDIN.gets().strip.to_f
            end
            if type=='every-this-day-of-the-month' then
                print "day number (String, length 2): "
                value = STDIN.gets().strip
            end
            if type=='every-this-day-of-the-week' then
                weekdays = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']
                value = LucilleCore::selectEntityFromListOfEntities_EnsureChoice("weekday: ", weekdays, lambda{|entity| entity })
            end
            schedule = {
                "uuid" => SecureRandom.hex,
                "@"    => type,
                "repeat-value" => value
            }
        end
        schedule
    end

    # Waves::unixtimeAtComingMidnight()
    def self.unixtimeAtComingMidnight()
        DateTime.parse("#{(DateTime.now.to_date+1).to_s} 00:00:00").to_time.to_i
    end

    # Waves::scheduleToDoNotShowUnixtime(uuid, schedule)
    def self.scheduleToDoNotShowUnixtime(uuid, schedule)
        if schedule['@'] == 'sticky' then
            return Waves::unixtimeAtComingMidnight() + 6*3600
        end
        if schedule['@'] == 'every-n-hours' then
            return Time.new.to_i+3600*schedule['repeat-value'].to_f
        end
        if schedule['@'] == 'every-n-days' then
            return Time.new.to_i+86400*schedule['repeat-value'].to_f
        end
        if schedule['@'] == 'every-this-day-of-the-month' then
            cursor = Time.new.to_i + 86400
            while Time.at(cursor).strftime("%d") != schedule['repeat-value'] do
                cursor = cursor + 3600
            end
           return cursor
        end
        if schedule['@'] == 'every-this-day-of-the-week' then
            mapping = ['sunday','monday','tuesday','wednesday','thursday','friday','saturday']
            cursor = Time.new.to_i + 86400
            while mapping[Time.at(cursor).wday]!=schedule['repeat-value'] do
                cursor = cursor + 3600
            end
            return cursor
        end
    end

    # Waves::scheduleToMetric(wave, schedule)
    def self.scheduleToMetric(wave, schedule)
        return 0 if !DoNotShowUntil::isVisible(wave["uuid"])
        if schedule['@'] == 'sticky' then # shows up once a day
            # Backward compatibility
            if schedule['from-hour'].nil? then
                schedule['from-hour'] = 6
            end
            return Time.new.hour >= schedule['from-hour'] ? ( 0.82 + Waves::traceToMetricShift(schedule["uuid"]) ) : 0
        end
        if schedule['@'] == 'every-this-day-of-the-month' then
            return 0.80 + Waves::traceToMetricShift(schedule["uuid"])
        end
        if schedule['@'] == 'every-this-day-of-the-week' then
            return 0.80 + Waves::traceToMetricShift(schedule["uuid"])
        end
        if schedule['@'] == 'every-n-hours' then
            return 0.65 + 0.05*Miscellaneous::metricCircle(wave["unixtime"])
        end
        if schedule['@'] == 'every-n-days' then
            return 0.65 + 0.05*Miscellaneous::metricCircle(wave["unixtime"])
        end
        1
    end

    # Waves::extractFirstLineFromText(text)
    def self.extractFirstLineFromText(text)
        return "" if text.size==0
        text.lines.first
    end

    # Waves::announce(text, schedule)
    def self.announce(text, schedule)
        "[#{Waves::scheduleToAnnounce(schedule)}] #{Waves::extractFirstLineFromText(text)}"
    end

    # Waves::scheduleToAnnounce(schedule)
    def self.scheduleToAnnounce(schedule)
        if schedule['@'] == 'sticky' then
            # Backward compatibility
            if schedule['from-hour'].nil? then
                schedule['from-hour'] = 6
            end
            return "sticky, from: #{schedule['from-hour']}"
        end
        if schedule['@'] == 'every-n-hours' then
            return "every-n-hours  #{"%6.1f" % schedule['repeat-value']}"
        end
        if schedule['@'] == 'every-n-days' then
            return "every-n-days   #{"%6.1f" % schedule['repeat-value']}"
        end
        if schedule['@'] == 'every-this-day-of-the-month' then
            return "every-this-day-of-the-month: #{schedule['repeat-value']}"
        end
        if schedule['@'] == 'every-this-day-of-the-week' then
            return "every-this-day-of-the-week: #{schedule['repeat-value']}"
        end
        JSON.generate(schedule)
    end

    # Waves::waveToCatalystObject(wave)
    def self.waveToCatalystObject(wave)
        uuid = wave["uuid"]
        schedule = wave["schedule"]
        announce = Waves::announce(wave["description"], schedule)
        object = {}
        object['uuid'] = uuid
        object["body"] = "[wave] " + announce
        object["metric"] = Waves::scheduleToMetric(wave, schedule)
        object["execute"] = lambda { |input|
            if input == ".." then
                Waves::openAndRunProcedure(wave)
                return
            end
            Waves::waveDive(wave)
        }
        object['schedule'] = schedule
        object["x-wave"] = wave
        object
    end

    # Waves::performDone(wave)
    def self.performDone(wave)
        unixtime = Waves::scheduleToDoNotShowUnixtime(wave["uuid"], wave['schedule'])
        DoNotShowUntil::setUnixtime(wave["uuid"], unixtime)
    end

    # Waves::commitToDisk(wave)
    def self.commitToDisk(wave)
        NyxObjects::put(wave)
    end

    # Waves::recommitToDisk(wave)
    def self.recommitToDisk(wave)
        NyxObjects::destroy(wave)
        NyxObjects::put(wave)
    end

    # Waves::issueWave(uuid, description, schedule)
    def self.issueWave(uuid, description, schedule)
        wave = {
            "uuid"             => uuid,
            "nyxNxSet"         => "7deb0315-98b5-4e4d-9ad2-d83c2f62e6d4",
            "unixtime" => Time.new.to_f,
            "description"      => description,
            "schedule"         => schedule
        }
        Waves::commitToDisk(wave)
        wave
    end

    # Waves::issueNewWaveInteractivelyOrNull()
    def self.issueNewWaveInteractivelyOrNull()
        line = LucilleCore::askQuestionAnswerAsString("line: ")
        schedule = Waves::makeScheduleObjectInteractivelyOrNull()
        return nil if schedule.nil?
        Waves::issueWave(LucilleCore::timeStringL22(), line, schedule)
    end

    # Waves::getOrNull(uuid)
    def self.getOrNull(uuid)
        NyxObjects::getOrNull(uuid)
    end

    # Waves::waves()
    def self.waves()
        NyxObjects::getSet("7deb0315-98b5-4e4d-9ad2-d83c2f62e6d4")
    end

    # Waves::waveToString(wave)
    def self.waveToString(wave)
        "[wave] #{wave["description"]}"
    end

    # Waves::catalystObjects()
    def self.catalystObjects()
        Waves::waves()
            .map{|obj| Waves::waveToCatalystObject(obj) }
    end

    # Waves::openItem(wave)
    def self.openItem(wave)
        text = wave["description"]
        puts text
        if text.lines.to_a.size == 1 and text.start_with?("http") then
            url = text
            if Waves::isLucille18() then
                system("open '#{url}'")
            else
                system("open -na 'Google Chrome' --args --new-window '#{url}'")
            end
            return
        end
        if text.lines.to_a.size > 1 then
            LucilleCore::pressEnterToContinue()
            return
        end
    end

    # Waves::openAndRunProcedure(wave)
    def self.openAndRunProcedure(wave)
        Waves::openItem(wave)
        if LucilleCore::askQuestionAnswerAsBoolean("-> done ? ", true) then
            Waves::performDone(wave)
        end
    end

    # Waves::searchNx1630(pattern)
    def self.searchNx1630(pattern)
        Waves::waves()
            .select{|wave|
                wave["description"].downcase.include?(pattern.downcase)
            }
            .map{|wave|
                {
                    "description"   => "[wave] #{wave["description"]}",
                    "referencetime" => wave["unixtime"],
                    "dive"          => lambda { Waves::waveDive(wave) }
                }
            }
    end

    # Waves::selectWaveOrNull()
    def self.selectWaveOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("wave", Waves::waves(), lambda {|wave| Waves::waveToString(wave) })
    end

    # Waves::waveDive(wave)
    def self.waveDive(wave)
        loop {
            system("clear")
            return if NyxObjects::getOrNull(wave["uuid"]).nil? # Could hve been destroyed in the previous loop
            puts Waves::waveToString(wave)
            puts "uuid: #{wave["uuid"]}"
            if DoNotShowUntil::isVisible(wave["uuid"]) then
                puts "active"
            else
                puts "hidden until: #{Time.at(DoNotShowUntil::getUnixtimeOrNull(wave["uuid"])).to_s}"
            end
            Miscellaneous::horizontalRule()

            menuitems = LCoreMenuItemsNX1.new()

            menuitems.item(
                "start",
                lambda {
                    Waves::openItem(wave)
                    if LucilleCore::askQuestionAnswerAsBoolean("-> done ? ", true) then
                        Waves::performDone(wave)
                    end
                }
            )

            menuitems.item(
                "open",
                lambda { Waves::openItem(wave) }
            )

            menuitems.item(
                "done",
                lambda { Waves::performDone(wave) }
            )

            menuitems.item(
                "description",
                lambda { 
                    description = Miscellaneous::editTextSynchronously(wave["description"])
                    return if description.nil?
                    wave["description"] = description
                    Waves::recommitToDisk(wave)
                }
            )

            menuitems.item(
                "recast",
                lambda { 
                    schedule = Waves::makeScheduleObjectInteractivelyOrNull()
                    return if schedule.nil?
                    wave["schedule"] = schedule
                    Waves::recommitToDisk(wave)
                }
            )

            menuitems.item(
                "destroy",
                lambda {
                    if LucilleCore::askQuestionAnswerAsBoolean("Do you want to destroy this item ? : ") then
                        NyxObjects::destroy(wave)
                    end
                }
            )

            Miscellaneous::horizontalRule()

            status = menuitems.prompt()
            break if !status
        }
    end

    # Waves::wavesDive()
    def self.wavesDive()
        system("clear")
        wave = Waves::selectWaveOrNull()
        return if wave.nil?
        Waves::waveDive(wave)
    end

    # Waves::main()
    def self.main()
        loop {
            system("clear")
            puts "Waves 🌊"
            options = [
                "new wave",
                "waves dive"
            ]
            option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", options)
            break if option.nil?
            if option == "new wave" then
                Waves::issueNewWaveInteractivelyOrNull()
            end
            if option == "waves dive" then
                Waves::wavesDive()
            end
        }
    end
end



