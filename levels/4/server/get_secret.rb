
def get_secret name:
  require "google/cloud/secret_manager"
  client = Google::Cloud::SecretManager.secret_manager_service
  version = client.access_secret_version name: name
  secret = version.payload.data
  puts secret
end

get_secret(name: ARGV[0])
