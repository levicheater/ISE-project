<?php

function generate_header($title_of_page)
{

    if (!isset($_SESSION)) {
        session_start();
    }
    $header = '<!DOCTYPE html>
<html lang="en">
<head>
    <title>' . $title_of_page . '</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.5.0/css/all.css" integrity="sha384-B4dIYHKNBt8Bc12p+WXckhzcICo0wtJAoU8YZTY5qE0Id1GSseTk6S+L3BlXeVIU" crossorigin="anonymous">
    <link rel="stylesheet" href="css/custom.css">
</head>
<header>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <a class="navbar-brand" href="index.php">BetaDi</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav"
                aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav">
                <li class="nav-item active">
                    <a class="nav-link" href="index.php">Home <span class="sr-only">(current)</span></a>
                </li>';

    if (isset($_SESSION['username'])) {
        if ($_SESSION['username'] == 'planner') {
            $header .= '<li class="nav-item active">
                            <a class="nav-link" href="createworkshop.php">Maak nieuwe workshop</a>
                        </li>
                        <li class="nav-item active">
                            <a class="nav-link" href="Openstaande_INC_aanvragen.php">Openstaande INC aanvragen</a>
                        </li>
                        <li class="nav-item active">
                            <a class="nav-link" href="allworkshops.php">Alle workshops</a>
                        </li>
                         <li class="nav-item active">
                            <a class="nav-link" href="LargeAccounts.php">Large Accounts</a>
                        </li>
                        <li class="nav-item active">
                            <a class="nav-link" href="reports.php">Rapportages</a>
                        </li>';
        } else if ($_SESSION['username'] == 'contactpersoon') {
            $header .= '<li class="nav-item active">
                <a class="nav-link" href="INCworkshop.php">INC inschrijving</a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="Openstaande_INC_aanvragen.php">Openstaande INC aanvragen</a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="Organisatie_workshops.php">Workshops</a>
            </li>';
        } else if ($_SESSION['username'] == 'deelnemer') {
            $header .= '<li class="nav-item active">
                <a class="nav-link" href="open_registrationform.php">Inschrijven voor open workshop</a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="signed_up_workshops.php">Ingeschreven workshops</a>
            </li>';
        }
        $header .= '<li class="nav-item">
                    <a class="nav-link">';

        if (isset($_SESSION['username'])) {
            if ($_SESSION['username'] == 'planner') {
                $header .= $_SESSION['username'] . '(' . $_SESSION['planner'] . ')';
            } elseif ($_SESSION['username'] == 'contactpersoon') {
                $header .= $_SESSION['username'] . '(' . getOrganisationName($_SESSION['organisation']) . ')';
            } elseif ($_SESSION['username'] == 'deelnemer'){
                $header .= $_SESSION['username']. '(' . $_SESSION['deelnemer_id'] . ')';
            } else {
                $header .= $_SESSION['username'];
            }
        }
    }
    $header .= '</a>
                </li>
            </ul>
        </div>
    </nav>
</header>';

    echo $header;
}


function check_input($data)
{
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);

    return $data;
}

function connectToDB()
{
    $hostnaam = '(local)';
    $dbnaam = 'SBBWorkshopOmgeving';
    $username = 'iseprojectuser';
    $wachtwoord = 'iseprojectww';

    try {
        $handler = new PDO("sqlsrv:Server=$hostnaam; Database=$dbnaam; ConnectionPooling=0", "$username", "$wachtwoord");

        $handler->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        echo "Er ging iets mis met de database.<br>";
        echo "De melding is {$e->getMessage()}<br><br>";
    }
    return $handler;
}


function selectBox($naamWaarde, $tabelnaam, $kolommen, $optionvalue, $displayColumns, $order, $function = null, $where = null)
{
    $handler = connectToDB();
    $select = '<select class="form-control" id="' . $naamWaarde . '" name="' . $naamWaarde . '" onchange="' . $function . '">';
    $select .= '<option value="">Selecteer uw optie.</option>';
    $kolomString = $kolommen[0];

    for ($i = 1; $i < sizeof($kolommen); $i++) {
        $kolomString .= ',' . $kolommen[$i];
    }

    $sql = "SELECT $kolomString FROM $tabelnaam";
    if (!is_null($where)) {
        $sql .= " WHERE " . $where;
    }

    $sql .= " ORDER BY " . $order;

    $query = $handler->prepare($sql);
    $query->execute();

    while ($resultaat = $query->fetch(PDO::FETCH_ASSOC)) {

        $displayString = '';

        if ($kolommen == $displayColumns) {

            foreach ($resultaat as $row) {
                $displayString .= $row . ' ';
            }
        } else {

            foreach (array_keys($resultaat) as $column) {
                if (in_array($column, $displayColumns)) {
                    $displayString .= $resultaat[$column] . ' ';
                }
            }
        }

        $select .= '<option value="' . $resultaat[$optionvalue] . '">' . $displayString . '</option>';

    }

    $select .= '</select>';

    return $select;
}


function pre_r($input)
{
    echo '<pre>';
    print_r($input);
    echo '</pre>';
}

function deleteUserWorkshop($workshop_id, $participant_id)
{
    $conn = connectToDB();

    //Run the stored procedure
    $sql = "exec SP_disapprove_participant_of_workshop ?, ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $workshop_id, PDO::PARAM_INT);
    $stmt->bindParam(2, $participant_id, PDO::PARAM_INT);
    $stmt->execute();
}

function deleteUserAanvraag($aanvraag_id, $participant_id)
{
    $conn = connectToDB();

    //Run the stored procedure
    $sql = "exec SP_remove_participant_from_workshoprequest ?, ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $aanvraag_id, PDO::PARAM_INT);
    $stmt->bindParam(2, $participant_id, PDO::PARAM_INT);
    $stmt->execute();
}

function addUser($workshop_id, $participant_id)
{
    $conn = connectToDB();

    //Run the stored procedure
    $sql = "exec SP_approve_participant_of_workshop ?, ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $workshop_id, PDO::PARAM_INT);
    $stmt->bindParam(2, $participant_id, PDO::PARAM_INT);
    $stmt->execute();
}

function updatePage($pagina)
{
    ?>
    <script type="text/javascript">
        window.location.href = '<?php echo $pagina ?>';
    </script>
    <?php
}

function getModuleNummer($id)
{
    $conn = connectToDB();

    //Run the stored procedure
    $sql = "exec SP_get_workshops @where = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $id, PDO::PARAM_INT);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $modulenummer = $row['MODULENUMMER'];

    return $modulenummer;
}

function getWorkshopType($id)
{
    $conn = connectToDB();


    $sql = "SELECT TYPE FROM WORKSHOP WHERE WORKSHOP_ID = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $id, PDO::PARAM_INT);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $workshoptype = $row['TYPE'];

    return $workshoptype;

}

function getGroupNumber($id)
{
    $conn = connectToDB();


    $sql = "SELECT TYPE FROM WORKSHOP WHERE WORKSHOP_ID = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $id, PDO::PARAM_INT);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $workshoptype = $row['TYPE'];

    return $workshoptype;

}

function getFirstGroup($aanvraag_id)
{
    $conn = connectToDB();

    $sql = "select top 1 GROEP_ID from GROEP where aanvraag_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $aanvraag_id, PDO::PARAM_INT);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $firstgroup = $row['GROEP_ID'];

    return $firstgroup;
}

function addUserToGroup($aanvraag_id, $groeps_id, $participant_id)
{
    $conn = connectToDB();

    $sql = "exec SP_add_participant_to_group ?, ?, ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $aanvraag_id, PDO::PARAM_INT);
    $stmt->bindParam(2, $groeps_id, PDO::PARAM_INT);
    $stmt->bindParam(3, $participant_id, PDO::PARAM_INT);
    $stmt->execute();
}


function deleteUserFromGroup($aanvraag_id, $groeps_id, $participant_id)
{
    $conn = connectToDB();

    $sql = "exec SP_remove_participant_from_group ?, ?, ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $aanvraag_id, PDO::PARAM_INT);
    $stmt->bindParam(2, $groeps_id, PDO::PARAM_INT);
    $stmt->bindParam(3, $participant_id, PDO::PARAM_INT);
    $stmt->execute();
}

function getRightGroepsNummer($groepss_id)
{
    $conn = connectToDB();

    $sql = "exec SP_get_row_numbers_of_group_ids ?, ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $_GET['aanvraag_id'], PDO::PARAM_INT);
    $stmt->bindParam(2, $groepss_id, PDO::PARAM_INT);
    $stmt->execute();

    $groepsnummer = $stmt->fetch(PDO::FETCH_ASSOC);

    return $groepsnummer['row_number_group'];
}

function sendMail($to, $subject, $body)
{
    require 'vendor/phpmailer/phpmailer/src/PHPMailer.php';

    require 'vendor/autoload.php';

    $mail = new PHPMailer\PHPMailer\PHPMailer();
    $mail->IsSMTP(); // enable SMTP
    $mail->SMTPDebug = 0; // debugging: 1 = errors and messages, 2 = messages only
    $mail->SMTPAuth = true; // authentication enabled
    $mail->SMTPSecure = 'ssl'; // secure transfer enabled REQUIRED for Gmail
    $mail->Host = "smtp.gmail.com";
    $mail->Port = 465;
    $mail->IsHTML(true);
    $mail->Username = "testISEB2@gmail.com";
    $mail->Password = "ise!b2MAILTEST";
    $mail->SetFrom("testISEB2@gmail.com");
    $mail->Subject = $subject;
    $mail->Body = $body;
    $mail->AddAddress($to);
    if (!$mail->Send()) {
        echo 'Message was not sent!.';
        echo 'Mailer error: ' . $mail->ErrorInfo;
    } else {
        echo 'Message was sent!.';
    }
}

function getCountOfWorkshopsForSector($sectorname)
{
    $conn = connectToDB();

    $sql = "EXEC SP_get_workshops_for_sector ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $sectorname, PDO::PARAM_STR);
    $stmt->execute();

    $nummer = 0;

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $nummer++;
    }

    return $nummer;
}

function getCountOfCancelledWorkshops()
{
    $conn = connectToDB();

    $sql = "EXEC SP_get_cancelled_workshops";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $nummer = 0;

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $nummer++;
    }

    return $nummer;
}

function getCountOfWorkshopsForWorkshopLeader($workshopleader)
{
    $conn = connectToDB();

    $sql = "EXEC SP_get_workshops_for_workshopleader ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $workshopleader, PDO::PARAM_INT);
    $stmt->execute();

    $nummer = 0;

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $nummer++;
    }

    return $nummer;
}

function getCountOfTypeWorkshops()
{
    $conn = connectToDB();

    $sql = "EXEC SP_get_count_workshoptypes";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $row = $stmt->fetchAll(PDO::FETCH_ASSOC);


    return $row;
}

function getCountOfAllWorkshops()
{
    $conn = connectToDB();

    $sql = "SELECT COUNT(WORKSHOP_ID) AS AANTAL FROM WORKSHOP";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row['AANTAL'];
}

function notLoggedIn()
{
    echo '<h1> U mag deze pagina niet bezoeken</h1>';
    header("refresh:1;url=index.php");
}

function getOrganisationName($organisationnumber)
{
    $conn = connectToDB();

    $sql = "SELECT ORGANISATIENAAM FROM ORGANISATIE WHERE ORGANISATIENUMMER = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $organisationnumber, PDO::PARAM_INT);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row['ORGANISATIENAAM'];
}

function getWorkshopleaderName($workshopleader_id)
{
    $conn = connectToDB();

    $sql = "select voornaam, achternaam from WORKSHOPLEIDER where WORKSHOPLEIDER_ID = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $workshopleader_id, PDO::PARAM_INT);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row;
}

function getCode() {
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    $code = array(); //remember to declare $pass as an array
    $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
    for ($i = 0; $i < 8; $i++) {
        $n = rand(0, $alphaLength);
        $code[] = $alphabet[$n];
    }
    return implode($code); //turn the array into a string
}

?>
