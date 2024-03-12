package com.rocket.device.info.strange_code.low_photo_detection;

import java.io.Serializable;

public class ᔿ implements Serializable {
    private static final long serialVersionUID = -1;
    private hn1 root = null;
    private long totalCount;

    public ᔿ() {
        m47033();
    }

    /* renamed from: ˊ */
    public synchronized void m47030(float f) {
        this.totalCount++;
        if (this.root == null) {
            this.root = new fn1();
        }
        this.root = this.root.m37061(this, f);
    }

    /* Access modifiers changed, original: protected */
    /* renamed from: ˋ */
    public int m47031() {
        int i = (int) (this.totalCount / 10);
        return i == 0 ? 1 : i;
    }

    /* renamed from: ˎ */
    public float m47032(int i) {
        long j = (this.totalCount * ((long) i)) / 100;
        Float f = new Float(0.0f);
        hn1 hn1 = this.root;
        if (hn1 != null) {
            f = hn1.m37062(new long[]{0, j});
        }
        return f != null ? f.floatValue() : 0.0f;
    }

    /* renamed from: ˏ */
    public void m47033() {
        hn1 hn1 = this.root;
        if (hn1 != null) {
            hn1.m37063();
            this.root = null;
        }
        this.totalCount = 0;
    }
}
