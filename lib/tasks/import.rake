task import: :environment do
  SyncCore.run
  SyncFromElmPackages.run
  SyncPackages.run
end
