package com.rocket.device.info.strange_code.low_photo_detection;

public final class mm {
    /* renamed from: ˊ */
    private final Long f33930;
    /* renamed from: ˋ */
    private final double f33931;
    /* renamed from: ˎ */
    private final double f33932;
    /* renamed from: ˏ */
    private final double f33933;

    public mm(Long l, double d, double d2, double d3) {
        this.f33930 = l;
        this.f33931 = d;
        this.f33932 = d2;
        this.f33933 = d3;
    }

    public String toString() {
        Long l = this.f33930;
        double d = this.f33931;
        double d2 = this.f33932;
        double d3 = this.f33933;
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("ClassifierThresholdItem(id=");
        stringBuilder.append(l);
        stringBuilder.append(", badDark=");
        stringBuilder.append(d);
        stringBuilder.append(", badBlurry=");
        stringBuilder.append(d2);
        stringBuilder.append(", badScore=");
        stringBuilder.append(d3);
        stringBuilder.append(")");
        return stringBuilder.toString();
    }

    /* renamed from: ˊ */
    public final double m40468() {
        return this.f33932;
    }

    /* renamed from: ˋ */
    public final double m40469() {
        return this.f33931;
    }

    /* renamed from: ˎ */
    public final double m40470() {
        return this.f33933;
    }

    /* renamed from: ˏ */
    public final Long m40471() {
        return this.f33930;
    }
}

