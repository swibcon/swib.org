---
pagetitle: "SWIB22: LOD Applications"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">LOD Applications</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Joachim Neubert, Julia Beck</div>

    



## Digital Scriptorium 2.0: toward a community-driven LOD knowledge base and national union catalog for premodern manuscripts

<b><u>L.P. Coladangelo</u>, Lynn Ransom, Doug Emery</b>



## The application of IIIF and LOD in digital humanities: a case study of the dictionary of wooden slips

<b><u>Shu-Jiun Chen</u>, Lu-Yen Lu</b>



## What linked data can tell about geographical trends in Finnish fiction literature – using the BookSampo knowledge graph in digital humanities

<b><u>Telma Peura</u>, Petri Leskinen, <u>Eero Hyvönen</u></b>



## Closing

<b></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2022-12-02T14:00:00");

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


