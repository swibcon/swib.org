---
pagetitle: "SWIB24: Workshop slot Europe / Africa"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Workshop slot Europe / Africa</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div></div>

    



## Introduction to the Annif automated indexing tool

<b><u>Osma Suominen</u>, <u>Mona Lehtinen</u>, Juho Inkinen, Anna Kasprzik, Ghulam Mustafa Majal, Lakshmi Rajendram Bashyam</b>



## Introduction to property graphs

<b><u>Jakob Voß</u></b>



## Leveraging Zurich Zentralbibliothek’s Jupyter Notebooks for metadata retrieval and analysis from Alma

<b><u>Linda Samsinger</u></b>



## The Open Research Knowledge Graph – a lighthouse in the publication flood

<b><u>Anna-Lena Lorenz</u></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-25T08:00:00");

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


