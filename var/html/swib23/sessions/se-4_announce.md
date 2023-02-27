---
pagetitle: "SWIB22: Continued Progress"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Continued Progress</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Osma Suominen, Uldis Bojars</div>

    



## New, newer, newest: incrementally integrating linked data into library catalog discovery

<b><u>Huda Khan</u>, <u>Steven Folsom</u>, <u>Astrid Usong</u></b>



## Improving language tags in cultural heritage data: a study of the metadata in Europeana

<b><u>Nuno Freire</u>, Paolo Scalia, Antoine Isaac, Eirini Kaldeli, Arne Stabenau</b>



## Evaluation and evolution of the Share-VDE 2.0 linked data catalog

<b><u>Jim Hahn</u>, <u>Beth Camden</u>, <u>Kayt Ahnberg</u>, <u>Filip Jakobsen</u></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2022-11-29T15:30:00");

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


