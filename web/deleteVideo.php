<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'connect2db.php';
    include 'head.php';
    include 'functions.php';
    if (isset($_REQUEST['ConfirmDelete'])) {
        $ConfirmDelete = $link->real_escape_string(trim($_REQUEST['ConfirmDelete']));
    } else {
        setMessage("Delete confirmation was not checked, not doing anything.","UploadPage.php");
        $NextURL = "UploadPage.php";
        header("Location: $NextURL");
        die;
    }
    if (isset($_REQUEST['v'])) {
        $v = $link->real_escape_string(trim($_REQUEST['v']));
    }

    if ($ConfirmDelete == "Confirmed") {
        #First, we must confirm ownership or adminship.
        if ($isAdministrator == 1) {
            $sql = "SELECT `vID`,`uploadDate`,`vTitle` from `Videos` WHERE `vID` = '$v' LIMIT 1";
        } else {
            $sql = "SELECT `vID`,`uploadDate`,`vTitle` from `Videos` WHERE `vID` = '$v' AND `vID` IN (SELECT `vID` FROM `UserVideoAssoc` WHERE `uID` = '$UserID') LIMIT 1";
        }


        $result = $link->query($sql);
        if ($result->num_rows > 0) {
            #Here owership or adminship is confirmed. Delete association row, then video row.
            $sql = "DELETE FROM `UserVideoAssoc` WHERE `vID` = '$v'";
            $link->query($sql);
            $sql = "DELETE FROM `Videos` WHERE `vID` = '$v'";
            $link->query($sql);
            if (copy("$videoDir/$v","$deleteDir/$v")) {
                unlink("$videoDir/$v");
                setMessage("Successful deletion","home.php");
		die;
            } else {
                setMessage("Delete failed","verifiedPlayer.php?v=$v");
            }
        } else {
            // Error
            $link->close();
            setMessage("Delete failed","verifiedPlayer.php?v=$v");
        }
    } else {
        $link->close();
        setMessage($invalidData,"verifiedPlayer.php?v=$v");
    }
}
?>

