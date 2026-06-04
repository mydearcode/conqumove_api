namespace :assets do
  desc "No-op asset precompile task for API-only deployments"
  task precompile: :environment do
    puts "Skipping assets:precompile for API-only app"
  end

  desc "No-op asset cleanup task for API-only deployments"
  task clean: :environment do
    puts "Skipping assets:clean for API-only app"
  end
end
