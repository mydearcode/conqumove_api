namespace :conqurun do
  namespace :territories do
    desc "Replay and rebuild territory read model from territory_events"
    task :rebuild, [:territory_id] => :environment do |_task, args|
      territory_id = args[:territory_id].presence

      if territory_id
        RebuildTerritoriesJob.perform_now(territory_id)
      else
        RebuildTerritoriesJob.perform_now
      end

      puts "Territory rebuild completed#{territory_id ? " for #{territory_id}" : ""}"
    end
  end
end
