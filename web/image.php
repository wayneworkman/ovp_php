<?php
$remoteImage = $_REQUEST['i'];
$remoteImage = "/data/qrCodes/$remoteImage.png";
$imginfo = getimagesize($remoteImage);
header("Content-type: {$imginfo['mime']}");
readfile($remoteImage);
?>
