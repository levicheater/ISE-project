<?php
if (!isset($_SESSION)) {
    session_start();
}

include 'functions.php';

if ($_SESSION['username'] == 'planner' or $_SESSION['username'] == 'contactpersoon') {

    $aanvraag_id = $_GET['aanvraag_id'];

    $name = $surname = $dateofbirth = $email = $phonenumber = $organisation  = $educational_attainment = '';

    $conn = connectToDB();

// The ones that do not get checked are dropdown or select.
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $name = check_input($_POST["name"]);
        $surname = check_input($_POST["surname"]);
        $dateofbirth = ($_POST["dateofbirth"]);
        $email = check_input($_POST["email"]);
        $phonenumber = check_input(@$_POST['phonenumber']);
        $organisation = check_input(@$_POST['organisation']);
        $educational_attainment = check_input(@$_POST['educational_attainment']);

        //Run the stored procedure
        $sql = "exec proc_insert_aanvraag_deelnemers ?, ?, ?, ?, ?, ?, ?, ?";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(1, $aanvraag_id, PDO::PARAM_INT);
        $stmt->bindParam(2, $name, PDO::PARAM_STR);
        $stmt->bindParam(3, $surname, PDO::PARAM_STR);
        $stmt->bindParam(4, $dateofbirth, PDO::PARAM_STR);
        $stmt->bindParam(5, $email, PDO::PARAM_STR);
        $stmt->bindParam(6, $phonenumber, PDO::PARAM_STR);
        $stmt->bindParam(7, $organisation, PDO::PARAM_INT);
        $stmt->bindParam(8, $educational_attainment, PDO::PARAM_STR);
        $stmt->execute();


    }

    generate_header('deelnemers');
    ?>

    <body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-2 col-sm-4 sidebar1">
                <div class="left-navigation">
                    <ul class="list">
                        <h5><strong>Aanvraag Opties</strong></h5>
                        <li>
                            <a href="participants.php?aanvraag_id=<?php echo $aanvraag_id ?>">Deelnemers en Groepen</a>
                        </li>
                        <li>
                            <a class="active-page">Voeg deelnemers toe</a>
                        </li>

                    </ul>
                    <br>
                </div>
            </div>
            <div class="col-md-10 col-sm-8 main-content">
                <!--Main content code to be written here -->
                <h1 class="headcenter">Voeg deelnemers toe</h1>
                <div>
                    <form class="form-group" action="addparticipant.php?aanvraag_id=<?php echo $aanvraag_id ?>" method="post">
                        <div class="form-group">
                            <label class="control-label col-sm-2 font-weight-bold" for="name">Voornaam:</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" placeholder="Voornaam" name="name">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label col-sm-2 font-weight-bold" for="surname">Achternaam:</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" placeholder="Achternaam" name="surname">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label col-sm-2 font-weight-bold"
                                   for="dateofbirth">Geboortedatum:</label>
                            <div class="col-sm-4">
                                <input type="date" class="form-control" placeholder="Geboortedatum" name="dateofbirth">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label col-sm-2 font-weight-bold" for="email">Emailadres:</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" placeholder="Emailadres" name="email">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label col-sm-2 font-weight-bold"
                                   for="phonenumber">Telefoonnummer:</label>
                            <div class="col-sm-4">
                                <input type="number" class="form-control" placeholder="Telefoonnummer"
                                       name="phonenumber">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label col-sm-2 font-weight-bold"
                                   for="organisation">Organisatie:</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" placeholder="Organisatie" name="organisation">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label col-sm-2 font-weight-bold" for="educational_attainment">Opleidingsniveau:</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" placeholder="Opleidingsniveau"
                                       name="educational_attainment">
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-sm-offset-2 col-sm-10">
                                <button type="submit" class="btn btn-default">Submit</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    </body>
    </html>
<?php } else {
    echo '<h1> Alleen planners kunnen deze pagina bezoeken</h1>';
}
include 'footer.html';


