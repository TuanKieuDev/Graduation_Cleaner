package com.rocket.device.info.strange_code.similar_detection;

import android.graphics.PointF;
import java.io.Serializable;

public class ly0 implements Serializable {
    private static final long serialVersionUID = 4545652412011631070L;
    private float confidence;
    private float eyeDistance;
    private float midX;
    private float midY;

    public ly0(PointF pointF, float f, float f2) {
        m40104(pointF);
        this.confidence = f2;
        this.eyeDistance = f;
    }

    /* renamed from: ˊ */
    public void m40104(PointF pointF) {
        this.midX = pointF.x;
        this.midY = pointF.y;
    }
}
