# Adds the rbs_rails tasks, which generate RBS for the Active Record models and the route helpers into sig/rbs_rails.
begin
  require "rbs_rails/rake_task"

  RbsRails::RakeTask.new
rescue LoadError
  # rbs_rails is a development gem, so production has no such tasks.
end
