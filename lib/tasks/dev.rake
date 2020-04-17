namespace :dev do
  namespace :db do
    task :reset do
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:seed'].invoke
      puts 'dev:db:reset Complete!'
    end
  end
end
