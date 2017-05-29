<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
                include 'connect2db.php';
		include 'functions.php';

                $sql = "DELETE FROM `Sessions` WHERE `fingerprint` = '$fingerprint'";


                if ($link->query($sql)) {
                        // good, send back to home.php
                        $NextURL="login.php";
                        header("Location: $NextURL");
                } else {
                        // Error
                        $link->close();
			setMessage($SiteErrorMessage,"home.php");
                }



} else {
        $NextURL="login.php";
        header("Location: $NextURL");
}
?>

