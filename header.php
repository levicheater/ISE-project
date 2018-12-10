<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"
      integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"
        integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"
        crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"
        integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"
        crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"
        integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"
        crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.5.0/css/all.css"
      integrity="sha384-B4dIYHKNBt8Bc12p+WXckhzcICo0wtJAoU8YZTY5qE0Id1GSseTk6S+L3BlXeVIU" crossorigin="anonymous">

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
                </li>
                <?php
                if (!isset($_SESSION)) {
                    session_start();
                }
                if (isset($_SESSION['username'])) {
                    if ($_SESSION['username'] == 'planner') { ?>
                        <li class="nav-item active">
                            <a class="nav-link" href="createworkshop.php">Maak nieuwe workshop</a>
                        </li>
                        <li class="nav-item active">
                            <a class="nav-link" href="Openstaande_INC_aanvragen.php">Openstaande INC aanvragen</a>
                        </li>
                        <li class="nav-item active">
                            <a class="nav-link" href="allworkshops.php">Alle workshops</a>
                        </li>
                        <?php
                    } else if ($_SESSION['username'] == 'contactpersoon') { ?>
                        <li class="nav-item active">
                            <a class="nav-link" href="INCworkshop.php">INC inschrijving</a>
                        </li>
                        <li class="nav-item active">
                            <a class="nav-link" href="Openstaande_INC_aanvragen.php">Openstaande INC aanvragen</a>
                        </li>
                    <?php }
                } ?>
                <li class="nav-item">
                    <a class="nav-link"><?php if (isset($_SESSION['username'])) {
                            echo $_SESSION['username'];
                        } ?></a>
                </li>

            </ul>
        </div>
    </nav>
</header>