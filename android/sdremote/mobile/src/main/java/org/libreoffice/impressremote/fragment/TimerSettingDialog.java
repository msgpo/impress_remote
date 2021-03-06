/* -*- Mode: Java; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/*
 * This file is part of the LibreOffice project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */
package org.libreoffice.impressremote.fragment;

import java.util.concurrent.TimeUnit;

import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatDialogFragment;
import android.support.v4.content.LocalBroadcastManager;
import android.widget.TimePicker;

import org.libreoffice.impressremote.R;
import org.libreoffice.impressremote.util.Intents;

public class TimerSettingDialog extends AppCompatDialogFragment implements TimePickerDialog.OnTimeSetListener {
    public static final String TAG = "TIMER_SETTING";

    private static final int INITIAL_HOUR = 0;
    private static final int INITIAL_MINUTE = 15;

    private static final boolean IS_24_HOUR_VIEW = true;

    private int mMinutes;

    public static TimerSettingDialog newInstance() {
        return new TimerSettingDialog();
    }

    @Override
    public Dialog onCreateDialog(Bundle aSavedInstanceState) {
        TimePickerDialog aDialog = new TimePickerDialog(getActivity(), this,
            INITIAL_HOUR, INITIAL_MINUTE, IS_24_HOUR_VIEW);

        aDialog.setTitle(R.string.title_timer);
        aDialog.setButton(TimePickerDialog.BUTTON_POSITIVE, getString(R.string.button_start), (DialogInterface.OnClickListener)null);

        return aDialog;
    }

    @Override
    public void onTimeSet(TimePicker aTimePicker, int aHour, int aMinute) {
        mMinutes = (int) (TimeUnit.HOURS.toMinutes(aHour) + aMinute);
        Intent aIntent = Intents.buildTimerStartedIntent(mMinutes);
        LocalBroadcastManager.getInstance(getActivity()).sendBroadcast(aIntent);
    }
}

/* vim:set shiftwidth=4 softtabstop=4 expandtab: */
