source (dirname (status --current-filename))/helpers.fish

@test "_coral_version prints current version" (_coral_version) = "0.2.1"
@test "coral --version prints current version" (coral --version) = "0.2.1"
