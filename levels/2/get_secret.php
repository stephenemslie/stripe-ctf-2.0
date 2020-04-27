<?php
declare(strict_types=1);

require_once __DIR__ . '/vendor/autoload.php';

use Google\Cloud\SecretManager\V1\SecretManagerServiceClient;

$client = new SecretManagerServiceClient();
$response = $client->accessSecretVersion($argv[1]);
$payload = $response->getPayload()->getData();
printf('%s', $payload);

?>
