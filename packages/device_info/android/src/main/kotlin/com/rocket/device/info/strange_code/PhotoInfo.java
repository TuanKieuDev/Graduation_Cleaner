package com.rocket.device.info.strange_code;

public final class PhotoInfo {
    private final String path;
    private long androidId;
    private long dateTaken;
    private int orientation;
    private double blurry;
    private double color;
    private double dark;
    private int facesCount;
    private double score;
    private boolean cvAnalyzed;

    private boolean wasAnalyzedForBadPhoto;
    private boolean isBad;

    public PhotoInfo(String path, long androidId, long dateTaken, int orientation, double blurry, double color, double dark, int facesCount, double score, boolean cvAnalyzed, boolean wasAnalyzedForBadPhoto, boolean isBad) {
        this.path = path;
        this.androidId = androidId;
        this.dateTaken = dateTaken;
        this.orientation = orientation;
        this.blurry = blurry;
        this.color = color;
        this.dark = dark;
        this.facesCount = facesCount;
        this.score = score;
        this.cvAnalyzed = cvAnalyzed;
        this.wasAnalyzedForBadPhoto = wasAnalyzedForBadPhoto;
        this.isBad = isBad;
    }

    public String toString() {
        String str = this.path;
        long j = this.androidId;
        long j2 = this.dateTaken;
        int i3 = this.orientation;
        double d = this.blurry;
        double d2 = this.color;
        double d3 = this.dark;
        double d4 = d2;
        int i4 = this.facesCount;
        double d5 = d3;
        double d6 = this.score;
        boolean z2 = this.cvAnalyzed;
        boolean z6 = this.isBad;
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(", path=");
        stringBuilder.append(str);
        stringBuilder.append(", androidId=");
        stringBuilder.append(j);
        stringBuilder.append(", date=");
        stringBuilder.append(j2);
        stringBuilder.append(", orientation=");
        stringBuilder.append(i3);
        stringBuilder.append(", blurry=");
        stringBuilder.append(d);
        stringBuilder.append(", color=");
        stringBuilder.append(d4);
        stringBuilder.append(", dark=");
        stringBuilder.append(d5);
        stringBuilder.append(", facesCount=");
        stringBuilder.append(i4);
        stringBuilder.append(", score=");
        stringBuilder.append(d6);
        stringBuilder.append(", cvAnalyzed=");
        stringBuilder.append(z2);
        stringBuilder.append(", isBad=");
        stringBuilder.append(z6);
        stringBuilder.append(")");

        return stringBuilder.toString();
    }

    public void setBlurry(double d) {
        this.blurry = d;
    }

    public double getDark() {
        return this.dark;
    }

    public long getDateTaken() {
        return this.dateTaken;
    }

    public int getFacesCount() {
        return this.facesCount;
    }

    public int getOrientation() {
        return this.orientation;
    }

    public String getPath() {
        return this.path;
    }

    public long getAndroidId() {
        return this.androidId;
    }

    public double getBlurry() {
        return this.blurry;
    }

    public double getColor() {
        return this.color;
    }

    public void setColor(double d) {
        this.color = d;
    }

    public void setCvAnalyzed(boolean z) {
        this.cvAnalyzed = z;
    }

    public void setDark(double d) {
        this.dark = d;
    }

    public void setFacesCount(int i) {
        this.facesCount = i;
    }

    public void setScore(double d) {
        this.score = d;
    }

    public double getScore() {
        return this.score;
    }

    public boolean isCVAnalyzed() {
        return this.cvAnalyzed;
    }
    public void setBadPhoto(boolean z) {
        this.isBad = z;
    }

    public boolean isBadPhoto() {
        return this.isBad;
    }

    public boolean isWasAnalyzedForBadPhoto() {
        return wasAnalyzedForBadPhoto;
    }

    public void setWasAnalyzedForBadPhoto(boolean wasAnalyzedForBadPhoto) {
        this.wasAnalyzedForBadPhoto = wasAnalyzedForBadPhoto;
    }
}
