<?php
$ips = array(
    '192.168.99.1',
    '127.0.0.1',
    '::1',
    '62.34.87.118', //chez ben
    '82.120.140.164', //nico1
    '212.198.73.234',//nico2
    '78.250.142.242',//sergio1
    '95.16.23.103', //antonio
    '212.194.217.129', // pepiniére 27
    '178.16.163.30',//pepiniere 2
    '92.243.17.0' //HTTP server (webservice test)
);
if (!(in_array(@$_SERVER['REMOTE_ADDR'],$ips)) && !(in_array(@$_SERVER['HTTP_X_FORWARDED_FOR'],$ips))) {
    header('HTTP/1.0 403 Forbidden');
    die('You are not allowed to access this file. Check '.basename(__FILE__).' for more information.');
}
