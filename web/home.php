<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'head.php';

    echo "Verified";

} else {
    echo "Not verified";
}
?>
