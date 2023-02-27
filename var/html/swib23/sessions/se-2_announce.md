---
pagetitle: "SWIB22: Linked Library Data I"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Linked Library Data I</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Jakob Voß, Huda Khan</div>

    



## Mapping and transforming MARC21 bibliographic metadata to LRM/RDA/RDF

<b><u>Theodore Gerontakos</u>, <u>Crystal Yragui</u>, <u>Zhuo Pan</u></b>



## A crosswalk in the park? Converting from MARC 21 to Linked Art

<b><u>Martin Lovell</u>, <u>Timothy A. Thompson</u></b>



## A LITL more quality: improving the correctness and completeness of library catalogs with a librarian-in-the-loop linked data workflow

<b><u>Sven Lieber</u>, Ann Van Camp, Hannes Lowagie</b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2022-11-28T15:30:00");

  var x = setInterval(function() {
    var now = moment();
    var t = startDate - now;

    var days = Math.floor( t / ( 1000 * 60 * 60 * 24 ));
    var hours = Math.floor((t%(1000 * 60 * 60 * 24))/(1000 * 60 * 60));
    var minutes = Math.floor((t % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((t % (1000 * 60)) / 1000);

    document.getElementById("countdown").innerHTML = days + "d "
        + hours + "h " + minutes + "m " + seconds + "s ";
    if (t < 0) {
      clearInterval(x);
      document.getElementById("countdown").innerHTML = "STARTING ...";
    }
  }, 1000);
</script>


