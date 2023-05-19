//to control the speed at which the sentences update we use the timer included in java.util
class SentenceChangeTimerTask extends TimerTask {
  public void run() {
    // Code to be executed when the timer triggers
    updateCurrSentence(); //update the current sentence index to change sentence
  }
}
//if for some reason we'll need to cancel the timer
/*
void stop() {
  // Cleanup code here
  timer.cancel();
  timer.purge();
  super.stop();
}
*/
