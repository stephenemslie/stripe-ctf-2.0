require 'logger'
require 'restclient'
require 'sinatra/cookies'
require_relative 'srv'

$log = Logger.new(STDERR)
$log.level = Logger::INFO

class CookieAuthenticatorSrv < DomainAuthenticator::DomainAuthenticatorSrv
  helpers Sinatra::Cookies

  def perform_authenticate(url, username, password)
    $log.info("Sending request to #{url}")
    headers = {}
    if cookies[:ctf]
      headers[:cookies] = { :ctf => cookies[:ctf] }
    end
    response = RestClient.post(
      url,
      {:password => password, :username => username},
      headers
    )
    body = response.body

    $log.info("Server responded with: #{body}")
    body
  end
end

def main
  CookieAuthenticatorSrv.run!
end

if $0 == __FILE__
  main
  exit(0)
end
