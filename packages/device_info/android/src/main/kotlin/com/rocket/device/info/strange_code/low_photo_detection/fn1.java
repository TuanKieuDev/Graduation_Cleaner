package com.rocket.device.info.strange_code.low_photo_detection;

public class fn1 extends hn1 {
    private static final long serialVersionUID = -1;
    private bk cell = new bk();

    public fn1() {
        m37063();
    }

    public fn1(long j, float f, float f2) {
        m37063();
        bk bkVar = this.cell;
        bkVar.count = j;
        bkVar.minValue = f;
        bkVar.maxValue = f2;
    }

    /* renamed from: ˏ */
    private float m37064(float f, float f2, float f3, float f4, float f5) {
        return f2 + (((f5 - f) * (f4 - f2)) / (f3 - f));
    }

    /* renamed from: ˊ */
    public hn1 m37061(ᔿ ᔿ, float f) {
        bk bkVar = this.cell;
        bk bkVar2;
        float f2;
        if (f >= bkVar.minValue && f <= bkVar.maxValue) {
            if (bkVar.count >= ((long) ᔿ.m47031())) {
                bkVar2 = this.cell;
                f2 = bkVar2.minValue;
                float f3 = bkVar2.maxValue;
                if (f2 != f3) {
                    long j;
                    f3 = (f3 + f2) / 2.0f;
                    long j2 = bkVar2.count;
                    long j3 = j2 / 2;
                    int i = j3 + j3 < j2 ? 1 : 0;
                    if (f > f3) {
                        j = 1 + j3;
                        j3 += (long) i;
                    } else {
                        long j4 = ((long) i) + j3;
                        j3++;
                        j = j4;
                    }
                    return new gn1(f3, new fn1(j3, f2, f3), new fn1(j, f3, this.cell.maxValue));
                }
            }
            bkVar2 = this.cell;
            bkVar2.count++;
        } else if (bkVar.count < ((long) ᔿ.m47031())) {
            bkVar2 = this.cell;
            bkVar2.count++;
            if (f < bkVar2.minValue) {
                bkVar2.minValue = f;
            }
            if (f > bkVar2.maxValue) {
                bkVar2.maxValue = f;
            }
        } else {
            bkVar2 = this.cell;
            f2 = bkVar2.minValue;
            float f4;
            if (f < f2) {
                bkVar2.minValue = Math.min(f2, (bkVar2.maxValue + f) / 2.0f);
                f4 = this.cell.minValue;
                return new gn1(f4, new fn1(1, f, f4), this);
            }
            bkVar2.maxValue = Math.max(bkVar2.maxValue, (f2 + f) / 2.0f);
            f4 = this.cell.maxValue;
            return new gn1(f4, this, new fn1(1, f4, f));
        }
        return this;
    }

    /* renamed from: ˋ */
    public Float m37062(long[] jArr) {
        Float f;
        long j = jArr[0];
        long j2 = jArr[1];
        if (j <= j2) {
            bk bkVar = this.cell;
            long j3 = bkVar.count;
            if (j + j3 >= j2) {
                float f2 = (float) j;
                float f3 = (float) (j + j3);
                float f4 = (float) j2;
                f = new Float(m37064(f2, bkVar.minValue, f3, bkVar.maxValue, f4));
                jArr[0] = jArr[0] + this.cell.count;
                return f;
            }
        }
        f = null;
        jArr[0] = jArr[0] + this.cell.count;
        return f;
    }

    /* renamed from: ˎ */
    public void m37063() {
        bk bkVar = this.cell;
        bkVar.count = 0;
        bkVar.minValue = Float.MAX_VALUE;
        bkVar.maxValue = -3.4028235E38f;
    }
}
