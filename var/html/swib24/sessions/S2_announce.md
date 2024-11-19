---
pagetitle: "SWIB24: Data & Interoperability"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Data & Interoperability</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Julia Beck, Uldis Bojars</div>

    



## CapData Opéra: ease data interoperability for opera houses

<b>Fabien Amarger, <u>Nicolas Chauvat</u>, Eudes Peyre</b>



## An aggregation workflow based on Linked Data for the common European data space for cultural heritage

<b><u>Nuno Freire</u>, <u>Bob Coret</u>, Enno Meijers, Hugo Manguinhas, Jochen Vermeulen, Antoine Isaac, Dimitra Atsidis</b>



## It is not all Greek anymore: use of LOD to increase the interoperability of data created by the National Library of Greece

<b><u>Sofia Zapounidou</u>, <u>Lazaros Ioannidis</u>, Michalis Gerolimos, Eftychia Koufakou, Charalampos Bratsas</b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-25T15:30:00");

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


