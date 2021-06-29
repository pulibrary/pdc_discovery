namespace :server do
  task initialize: :environment do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end

  desc "Start solr and postgres servers using lando."
  task start: :environment do
    system("lando start")
  end

  desc "Stop lando solr and postgres servers."
  task stop: :environment do
    system("lando stop")
  end
end
