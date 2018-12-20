<?php
if (!isset($_SESSION)) {
    session_start();
}

include 'functions.php';

if ($_SESSION['username'] == 'planner' or $_SESSION['username'] == 'contactpersoon') {

    $workshop_id = $_GET['workshop_id'];

    $name = $surname = $dateofbirth = $email = $phonenumber = $educational_attainment = '';

    $conn = connectToDB();

// The ones that do not get checked are dropdown or select.
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $name = check_input($_POST["name"]);
        $surname = check_input($_POST["surname"]);
        $dateofbirth = ($_POST["dateofbirth"]);
        $email = check_input($_POST["emailaddress"]);
        $phonenumber = check_input(@$_POST['phonenumber']);
        $educational_attainment = check_input(@$_POST['educational_attainment']);

        //Run the stored procedure
        $sql = "exec SP_insert_deelnemer_in_workshop ?, ?, ?, ?, ?, ?, ?";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(1, $aanvraag_id, PDO::PARAM_INT);
        $stmt->bindParam(2, $name, PDO::PARAM_STR);
        $stmt->bindParam(3, $surname, PDO::PARAM_STR);
        $stmt->bindParam(4, $dateofbirth, PDO::PARAM_STR);
        $stmt->bindParam(5, $email, PDO::PARAM_STR);
        $stmt->bindParam(6, $phonenumber, PDO::PARAM_STR);
        $stmt->bindParam(7, $educational_attainment, PDO::PARAM_STR);
        $stmt->execute();
    }

    generate_header('Deelnemers toevoegen');

    $group = getFirstGroup($aanvraag_id);
    ?>
    <html lang="en">
    <body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-2 col-sm-4 sidebar1">
                <div class="left-navigation">
                    <ul class="list">
                        <h5><strong>Workshop Opties</strong></h5>
                        <li>
                            <a href="workshop.php?workshop_id=<?= $workshop_id ?>">Details</a>
                        </li>
                        <li>
                            <a href="open_workshop_participants.php?workshop_id=<?= $workshop_id ?>">Deelnemers</a>
                        </li>
                        <li>
                            <a href="open_registrations.php?workshop_id=<?= $workshop_id ?>">Openstaande inschrijvingen</a>
                        </li>
                        <li>
                            <a href="reservelist.php?workshop_id=<?= $workshop_id ?>">Reservelijst</a>
                        </li>
                        <li>
                            <a href="editworkshop.php?workshop_id=<?= $workshop_id ?>" >Wijzig workshop</a>
                        </li>
                        <li>
                            <a class="active-page">Voeg deelnemers toe</a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="col-md-10 col-sm-8 main-content">
                <h1>Deelnemers</h1>
                <table class='table table-striped table-hover'>
                    <tr>
                        <th>Naam</th>
                        <th>Geboortedatum</th>
                        <th>Opleidingsniveau</th>
                        <th>Groep</th>
                        <th>Email</th>
                        <th>Telefoonnummer</th>
                        <th>Verwijderen</th>
                    </tr>
                    <?php

                    //Run the stored procedure
                    $sql = "exec SP_get_participants_of_workshoprequest ?";
                    $stmt = $conn->prepare($sql);
                    $stmt->bindParam(1, $aanvraag_id, PDO::PARAM_INT);
                    $stmt->execute();

                    $nummer = 0;

                    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                        $nummer++;
                        $html = '';
                        $html .= '<tr>';
                        $html .= '<td>';
                        $html .= $row['VOORNAAM'] . ' ' . $row['ACHTERNAAM'];
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= $row['GEBOORTEDATUM'];
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= $row['OPLEIDINGSNIVEAU'];
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= getRightGroepsNummer($row['GROEP_ID']);
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= $row['EMAIL'];
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= $row['TELEFOONNUMMER'];
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= '<a class="fas fa-times" id="denybutton" onclick="return confirm(\'Weet je zeker dat je deze persoon wilt verwijderen? Zijn of haar gegevens worden niet opgeslagen\')" href="addparticipant.php?aanvraag_id=' . $aanvraag_id . '&participant_id=' . $row['DEELNEMER_ID'] . '&deleteUser=true"></a>';
                        $html .= '</td>';
                        $html .= '</tr>';

                        echo $html;

                    }
                    if (isset($_GET['deleteUser'])) {
                        deleteUserAanvraag($aanvraag_id, $_GET['participant_id']);
                        updatePage($_SERVER['PHP_SELF'] . '?aanvraag_id=' . $aanvraag_id);
                    }

                    ?>
                </table>
                <h1 class="headcenter">Voeg deelnemers toe</h1>
                <div>
                    <form action="?aanvraag_id=<?= $aanvraag_id ?>" method="post">
                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label for="name">Voornaam</label>
                                <input type="text" class="form-control" placeholder="Voornaam" name="name" required>
                            </div>
                            <div class="form-group col-md-6">
                                <label for="surname">Achternaam</label>
                                <input type="text" class="form-control" placeholder="Achternaam" name="surname"
                                       required>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label for="dateofbirth">Geboortedatum</label>
                                <input type="date" class="form-control" placeholder="Geboortedatum" name="dateofbirth"
                                       required>
                            </div>
                            <div class="form-group col-md-6">
                                <label for="dateofbirth">Opleidingsniveau</label>
                                <input type="text" class="form-control" placeholder="Opleidingsniveau"
                                       name="educational_attainment" required>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label for="phonenumber">Telefoonnummer</label>
                                <input type="number" class="form-control" placeholder="Telefoonnummer"
                                       name="phonenumber" max="999999999999" required>
                            </div>
                            <div class="form-group col-md-6">
                                <label for="emailaddress">Emailadres</label>
                                <input type="email" class="form-control" placeholder="Emailadres" name="emailaddress"
                                       required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">Maak nieuwe deelnemer</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    </body>
    </html>
<?php } else {
    notLoggedIn();
}
include 'footer.html';

