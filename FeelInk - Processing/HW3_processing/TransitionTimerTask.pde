class TransitionTimerTask extends TimerTask {
  public void run() {
    // Code to be executed when the timer triggers
    isChangingState = false; //update the current sentence index to change sentence
  }
}
