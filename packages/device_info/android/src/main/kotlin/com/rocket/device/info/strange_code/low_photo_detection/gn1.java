package com.rocket.device.info.strange_code.low_photo_detection;

public class gn1 extends hn1 {
    private static final long serialVersionUID = -1;
    private hn1 left;
    private hn1 right;
    private float splitValue;

    public gn1(float f, hn1 hn1, hn1 hn12) {
        this.splitValue = f;
        this.left = hn1;
        this.right = hn12;
    }

    /* renamed from: ˊ */
    public hn1 m37061(ᔿ ᔿ, float f) {
        if (f > this.splitValue) {
            this.right = this.right.m37061(ᔿ, f);
        } else {
            this.left = this.left.m37061(ᔿ, f);
        }
        return this;
    }

    /* renamed from: ˋ */
    public Float m37062(long[] jArr) {
        Float ˋ = this.left.m37062(jArr);
        return ˋ == null ? this.right.m37062(jArr) : ˋ;
    }

    /* renamed from: ˎ */
    public void m37063() {
        hn1 hn1 = this.left;
        if (hn1 != null) {
            hn1.m37063();
            this.left = null;
        }
        hn1 = this.right;
        if (hn1 != null) {
            hn1.m37063();
            this.right = null;
        }
        this.splitValue = 0.0f;
    }
}
