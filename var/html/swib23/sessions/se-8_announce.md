---
pagetitle: "SWIB22: Machine Learning"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Machine Learning</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Nuno Freire, Huda Khan</div>

    



## How are data collections and vocabularies teaching AI systems human stereotypes?

<b><u>Artem Reshetnikov</u></b>



## Insight into the machine-based subject cataloguing at the German National Library

<b><u>Christoph Poley</u></b>



## Multilingual BERT for library classification in Romance languages using Basisklassifikation

<b><u>José Calvo Tello</u>, <u>Enrique Manjavacas</u>, Susanne Al-Eryani</b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2022-12-01T15:30:00");

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


