class EmotionMapper {
    private Map<Range, String> emotionMapping1 = new HashMap<>();
    private Map<Range, String> emotionMapping2 = new HashMap<>();
    //HAPPY CALM SAD FURIOUS
    public EmotionMapper(){
        // Define the mapping of ranges to emotions
        emotionMapping1.put(new Range(346, 360), "HAPPY");
        emotionMapping1.put(new Range(340, 346), "FURIOUS");
        emotionMapping1.put(new Range(2, 8), "FURIOUS");
        emotionMapping1.put(new Range(336, 340), "HAPPY");
        emotionMapping1.put(new Range(8, 12), "HAPPY");
        emotionMapping1.put(new Range(332, 336), "FURIOUS");
        emotionMapping1.put(new Range(12, 15), "FURIOUS");
        emotionMapping1.put(new Range(288, 306), "HAPPY");
        emotionMapping1.put(new Range(280, 288), "CALM");
        emotionMapping1.put(new Range(306, 314), "CALM");
        emotionMapping1.put(new Range(271, 280), "CALM");
        emotionMapping1.put(new Range(315, 323), "CALM");
        emotionMapping1.put(new Range(262, 271), "CALM");
        emotionMapping1.put(new Range(323, 331), "CALM");
        emotionMapping1.put(new Range(210, 238), "CALM");
        emotionMapping1.put(new Range(197, 210), "HAPPY");
        emotionMapping1.put(new Range(238, 251), "HAPPY");
        emotionMapping1.put(new Range(188, 197), "CALM");
        emotionMapping1.put(new Range(251, 261), "CALM");
        emotionMapping1.put(new Range(164, 174), "HAPPY");
        emotionMapping1.put(new Range(159, 164), "CALM");
        emotionMapping1.put(new Range(175, 179), "CALM");
        emotionMapping1.put(new Range(155, 159), "HAPPY");
        emotionMapping1.put(new Range(179, 184), "HAPPY");
        emotionMapping1.put(new Range(150, 155), "HAPPY");
        emotionMapping1.put(new Range(184, 187), "HAPPY");
        emotionMapping1.put(new Range(98, 118), "HAPPY");
        emotionMapping1.put(new Range(90, 98), "HAPPY");
        emotionMapping1.put(new Range(118, 126), "HAPPY");
        emotionMapping1.put(new Range(82, 90), "HAPPY");
        emotionMapping1.put(new Range(126, 134), "HAPPY");
        emotionMapping1.put(new Range(74, 82), "CALM");
        emotionMapping1.put(new Range(134, 142), "CALM");
        emotionMapping1.put(new Range(66, 74), "CALM");
        emotionMapping1.put(new Range(142, 149), "CALM");
        emotionMapping1.put(new Range(52, 59), "HAPPY");
        emotionMapping1.put(new Range(49, 52), "HAPPY");
        emotionMapping1.put(new Range(59, 63), "HAPPY");
        emotionMapping1.put(new Range(48, 48), "HAPPY");
        emotionMapping1.put(new Range(62, 65), "HAPPY");
        emotionMapping1.put(new Range(27, 38), "HAPPY");
        emotionMapping1.put(new Range(21, 27), "HAPPY");
        emotionMapping1.put(new Range(38, 43), "HAPPY");
        emotionMapping1.put(new Range(16,21), "HAPPY");
        emotionMapping1.put(new Range(43, 47), "HAPPY");
        
        
        // WHITE SECTION
        emotionMapping2.put(new Range(84, 95), "CALM");
        emotionMapping2.put(new Range(80, 84), "HAPPY");
        emotionMapping2.put(new Range(95, 100), "HAPPY");
        
        // GRAY SECTION
        emotionMapping2.put(new Range(52, 68), "SAD");
        emotionMapping2.put(new Range(45, 52), "SAD");
        emotionMapping2.put(new Range(68, 75), "SAD");
        emotionMapping2.put(new Range(39, 45), "SAD");
        emotionMapping2.put(new Range(75, 80), "SAD");
        
        // BLACK SECTION
        emotionMapping2.put(new Range(14, 24), "SAD");
        emotionMapping2.put(new Range(10, 14), "FURIOUS");
        emotionMapping2.put(new Range(24, 29), "FURIOUS");
        emotionMapping2.put(new Range(6, 10), "FURIOUS");
        emotionMapping2.put(new Range(29, 32), "FURIOUS");
        emotionMapping2.put(new Range(3, 6), "FURIOUS");
        emotionMapping2.put(new Range(32, 35), "FURIOUS");
        emotionMapping2.put(new Range(0, 3), "SAD");
        emotionMapping2.put(new Range(35, 38), "SAD");
    }
    
    // Find the emotion based on the given Hue value
    public String findEmotion(int hue, int mode) {
      switch (mode){
        //see HW3 processing for exaplantions on "mode"
        case 0:
        for (Range range : emotionMapping1.keySet()) {
            if (range.contains(hue)) {
                return emotionMapping1.get(range);
            }
        }
        break;
        case 1:
        for (Range range : emotionMapping2.keySet()) {
            if (range.contains(hue)) {
                return emotionMapping2.get(range);
            }
        }
        break;
      }
        return null;
    }
    
    // Range class to represent a range of values
    private class Range {
        private final int start;
        private final int end;
        
        public Range(int start, int end) {
            this.start = start;
            this.end = end;
        }
        
        public boolean contains(int value) {
            return value >= start && value <= end;
        }
    }
}
