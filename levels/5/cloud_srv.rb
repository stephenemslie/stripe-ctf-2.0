require 'logger'
require 'restclient'
require_relative 'srv'

$log = Logger.new(STDERR)
$log.level = Logger::INFO

class TokenDomainAuthenticatorSrv < DomainAuthenticator::DomainAuthenticatorSrv
  def perform_authenticate(url, username, password)
    metadata_url = 'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity?audience='
    response = RestClient.get(metadata_url+url, {'Metadata-Flavor' => 'Google'})
    token = response.body
    $log.info("Sending request to #{url}")
    response = RestClient.post(url,
                               {:password => password, :username => username},
                               {:Authorization => 'Bearer ' + token})
    body = response.body

    $log.info("Server responded with: #{body}")
    body
  end
end

def main
  TokenDomainAuthenticatorSrv.run!
end

if $0 == __FILE__
  main
  exit(0)
end
