---
pagetitle: "SWIB24: LOD for End Users"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">LOD for End Users</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: MJ Suhonos, Julia Beck</div>

    



## Empowering user discovery with Linked Data and Semantic Web technologies

<b><u>Min Hoon Ee</u>, Ashwin Nair, Robin Dresel</b>



## Setting the stage: enabling curation spaces for dialogues with Ibali Digital Collections UCT

<b><u>Sanjin Muftic</u></b>



## E-LAUTE: establishing a music edition platform using Semantic Web technologies

<b><u>Ilias Kyriazis</u>, <u>David M. Weigl</u>, Christoph Steindl</b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-26T15:30:00");

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


