#!/system/bin/sh

ui_print "**************************************************"
ui_print "       One UI Floating Feature Patcher            "
ui_print "**************************************************"

# 1. Locate original file strictly in /system/etc/
if [ -f "/system/etc/floating_feature.xml" ]; then
    ORIG_FILE="/system/etc/floating_feature.xml"
    TARGET_DIR="$MODPATH/system/etc"
else
    abort "! Error: /system/etc/floating_feature.xml not found on this ROM."
fi

TARGET_FILE="$TARGET_DIR/floating_feature.xml"

# Prepare target directory and copy original file
ui_print "- Preparing systemless directory..."
mkdir -p "$TARGET_DIR"

ui_print "- Copying stock floating_feature.xml..."
cp "$ORIG_FILE" "$TARGET_FILE"
set_perm 0 0 0644 "$TARGET_FILE"

ui_print "--------------------------------------------------"
ui_print "Applying XML Feature Patches ..."
ui_print "--------------------------------------------------"

# ==================================================================
# FLOATING FEATURE XML PATCHES (Alphabetical Order)
# ==================================================================

# ------------------------------------------------------------------
# 1. CAMERA_CONFIG_STRIDE_OCR_VERSION
# ------------------------------------------------------------------
OCR_TAG="SEC_FLOATING_FEATURE_CAMERA_CONFIG_STRIDE_OCR_VERSION"
OCR_LINE="    <SEC_FLOATING_FEATURE_CAMERA_CONFIG_STRIDE_OCR_VERSION>V2</SEC_FLOATING_FEATURE_CAMERA_CONFIG_STRIDE_OCR_VERSION>"

if ! grep -q "$OCR_TAG" "$TARGET_FILE"; then
    ui_print " > Adding Camera Stride OCR Version V2"
    sed -i "/<\/secfloatingfeature>/i $OCR_LINE" "$TARGET_FILE"
else
    ui_print " - Camera Stride OCR Version already present"
fi

# ------------------------------------------------------------------
# 2. CAMERA_SUPPORT_PRIVACY_TOGGLE
# ------------------------------------------------------------------
PRIVACY_TAG="SEC_FLOATING_FEATURE_CAMERA_SUPPORT_PRIVACY_TOGGLE"
PRIVACY_LINE="    <SEC_FLOATING_FEATURE_CAMERA_SUPPORT_PRIVACY_TOGGLE>TRUE</SEC_FLOATING_FEATURE_CAMERA_SUPPORT_PRIVACY_TOGGLE>"

if ! grep -q "$PRIVACY_TAG" "$TARGET_FILE"; then
    ui_print " > Adding Camera Support Privacy Toggle"
    sed -i "/<\/secfloatingfeature>/i $PRIVACY_LINE" "$TARGET_FILE"
else
    ui_print " - Camera Support Privacy Toggle already present"
fi

# ------------------------------------------------------------------
# 3. COMMON_SUPPORT_HIGH_PERFORMANCE_MODE
# ------------------------------------------------------------------
PERF_TAG="SEC_FLOATING_FEATURE_COMMON_SUPPORT_HIGH_PERFORMANCE_MODE"
PERF_LINE="    <SEC_FLOATING_FEATURE_COMMON_SUPPORT_HIGH_PERFORMANCE_MODE>TRUE</SEC_FLOATING_FEATURE_COMMON_SUPPORT_HIGH_PERFORMANCE_MODE>"

if ! grep -q "$PERF_TAG" "$TARGET_FILE"; then
    ui_print " > Adding High Performance Mode"
    sed -i "/<\/secfloatingfeature>/i $PERF_LINE" "$TARGET_FILE"
else
    ui_print " - High Performance Mode already present"
fi

# ------------------------------------------------------------------
# 4. FRAMEWORK_CONFIG_AOD_ITEM
# ------------------------------------------------------------------
AOD_TAG="SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_AOD_ITEM"

if grep -q "$AOD_TAG" "$TARGET_FILE"; then
    ui_print " > Patching AOD item configurations"
    if ! grep "$AOD_TAG" "$TARGET_FILE" | grep -q "clocktransition"; then
        if grep -q "<${AOD_TAG}></${AOD_TAG}>" "$TARGET_FILE"; then
            sed -i "s|<${AOD_TAG}></${AOD_TAG}>|<${AOD_TAG}>clocktransition</${AOD_TAG}>|g" "$TARGET_FILE"
        else
            sed -i "s|</${AOD_TAG}>|,clocktransition</${AOD_TAG}>|g" "$TARGET_FILE"
        fi
    fi

    if ! grep "$AOD_TAG" "$TARGET_FILE" | grep -q "activeclock=4"; then
        if grep -q "<${AOD_TAG}></${AOD_TAG}>" "$TARGET_FILE"; then
            sed -i "s|<${AOD_TAG}></${AOD_TAG}>|<${AOD_TAG}>activeclock=4</${AOD_TAG}>|g" "$TARGET_FILE"
        else
            sed -i "s|</${AOD_TAG}>|,activeclock=4</${AOD_TAG}>|g" "$TARGET_FILE"
        fi
    fi
else
    ui_print " - AOD tag missing; skipping AOD patch"
fi

# ------------------------------------------------------------------
# 5. FRAMEWORK_CONFIG_SCREEN_RECORDER_ITEM
# ------------------------------------------------------------------
RECORDER_ITEM_TAG="SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_SCREEN_RECORDER_ITEM"
RECORDER_ITEM_LINE="    <SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_SCREEN_RECORDER_ITEM>-pip</SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_SCREEN_RECORDER_ITEM>"

if ! grep -q "$RECORDER_ITEM_TAG" "$TARGET_FILE"; then
    ui_print " > Adding Screen Recorder Item (-pip)"
    sed -i "/<\/secfloatingfeature>/i $RECORDER_ITEM_LINE" "$TARGET_FILE"
else
    ui_print " - Screen Recorder Item already present"
fi

# ------------------------------------------------------------------
# 6. FRAMEWORK_SUPPORT_SCREEN_RECORDER
# ------------------------------------------------------------------
RECORDER_TAG="SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_SCREEN_RECORDER"
RECORDER_LINE="    <SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_SCREEN_RECORDER>TRUE</SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_SCREEN_RECORDER>"

if ! grep -q "$RECORDER_TAG" "$TARGET_FILE"; then
    ui_print " > Adding Native Screen Recorder"
    sed -i "/<\/secfloatingfeature>/i $RECORDER_LINE" "$TARGET_FILE"
else
    ui_print " - Screen Recorder feature already present"
fi

# ------------------------------------------------------------------
# 7. LAUNCHER_CONFIG_ANIMATION_TYPE
# ------------------------------------------------------------------
ANIM_TAG="SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE"
NEW_ANIM_LINE="    <SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE>CNHighEnd</SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE>"

if grep -q "$ANIM_TAG" "$TARGET_FILE"; then
    ui_print " > Forcing CNHighEnd Launcher Animation Type"
    sed -i "s|<${ANIM_TAG}>.*</${ANIM_TAG}>|<${ANIM_TAG}>CNHighEnd</${ANIM_TAG}>|g" "$TARGET_FILE"
else
    ui_print " > Adding Launcher Animation Type tag"
    sed -i "/<\/secfloatingfeature>/i $NEW_ANIM_LINE" "$TARGET_FILE"
fi

# ------------------------------------------------------------------
# 8. LAUNCHER_CONFIG_ZERO_PAGE_PACKAGE_NAMES
# ------------------------------------------------------------------
ZERO_TAG="SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ZERO_PAGE_PACKAGE_NAMES"
FULL_ZERO_LINE="    <SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ZERO_PAGE_PACKAGE_NAMES>com.google.android.googlequicksearchbox,com.samsung.android.app.spage</SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ZERO_PAGE_PACKAGE_NAMES>"

if grep -q "$ZERO_TAG" "$TARGET_FILE"; then
    ui_print " > Checking Zero Page package names"
    if ! grep "$ZERO_TAG" "$TARGET_FILE" | grep -q "com.google.android.googlequicksearchbox"; then
        if grep -q "<${ZERO_TAG}></${ZERO_TAG}>" "$TARGET_FILE"; then
            sed -i "s|<${ZERO_TAG}></${ZERO_TAG}>|<${ZERO_TAG}>com.google.android.googlequicksearchbox</${ZERO_TAG}>|g" "$TARGET_FILE"
        else
            sed -i "s|</${ZERO_TAG}>|,com.google.android.googlequicksearchbox</${ZERO_TAG}>|g" "$TARGET_FILE"
        fi
    fi

    if ! grep "$ZERO_TAG" "$TARGET_FILE" | grep -q "com.samsung.android.app.spage"; then
        if grep -q "<${ZERO_TAG}></${ZERO_TAG}>" "$TARGET_FILE"; then
            sed -i "s|<${ZERO_TAG}></${ZERO_TAG}>|<${ZERO_TAG}>com.samsung.android.app.spage</${ZERO_TAG}>|g" "$TARGET_FILE"
        else
            sed -i "s|</${ZERO_TAG}>|,com.samsung.android.app.spage</${ZERO_TAG}>|g" "$TARGET_FILE"
        fi
    fi
else
    ui_print " > Adding Zero Page package names line"
    sed -i "/<\/secfloatingfeature>/i $FULL_ZERO_LINE" "$TARGET_FILE"
fi

# ------------------------------------------------------------------
# 9. SYSTEM_SUPPORT_ENHANCED_CPU_RESPONSIVENESS
# ------------------------------------------------------------------
CPU_TAG="SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_ENHANCED_CPU_RESPONSIVENESS"
CPU_LINE="    <SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_ENHANCED_CPU_RESPONSIVENESS>TRUE</SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_ENHANCED_CPU_RESPONSIVENESS>"

if ! grep -q "$CPU_TAG" "$TARGET_FILE"; then
    ui_print " > Adding Enhanced CPU Responsiveness"
    sed -i "/<\/secfloatingfeature>/i $CPU_LINE" "$TARGET_FILE"
else
    ui_print " - Enhanced CPU Responsiveness already present"
fi

# ------------------------------------------------------------------
# 10. SYSTEMUI_CONFIG_EDGELIGHTING_FRAME_EFFECT
# ------------------------------------------------------------------
EDGE_TAG="SEC_FLOATING_FEATURE_SYSTEMUI_CONFIG_EDGELIGHTING_FRAME_EFFECT"
EDGE_LINE="    <SEC_FLOATING_FEATURE_SYSTEMUI_CONFIG_EDGELIGHTING_FRAME_EFFECT>frame_effect</SEC_FLOATING_FEATURE_SYSTEMUI_CONFIG_EDGELIGHTING_FRAME_EFFECT>"

if grep -q "$EDGE_TAG" "$TARGET_FILE"; then
    ui_print " > Setting Edge Lighting Frame Effect to 'frame_effect'"
    sed -i "s|<${EDGE_TAG}>.*</${EDGE_TAG}>|<${EDGE_TAG}>frame_effect</${EDGE_TAG}>|g" "$TARGET_FILE"
else
    ui_print " > Adding Edge Lighting Frame Effect tag"
    sed -i "/<\/secfloatingfeature>/i $EDGE_LINE" "$TARGET_FILE"
fi

# ------------------------------------------------------------------
# 11. VOICERECORDER_CONFIG_DEF_MODE
# ------------------------------------------------------------------
VOICE_TAG="SEC_FLOATING_FEATURE_VOICERECORDER_CONFIG_DEF_MODE"
NEW_VOICE_LINE="    <SEC_FLOATING_FEATURE_VOICERECORDER_CONFIG_DEF_MODE>normal,interview,voicememo</SEC_FLOATING_FEATURE_VOICERECORDER_CONFIG_DEF_MODE>"

if grep -q "$VOICE_TAG" "$TARGET_FILE"; then
    ui_print " > Updating Voice Recorder mode value"
    sed -i "s|<${VOICE_TAG}>.*</${VOICE_TAG}>|<${VOICE_TAG}>normal,interview,voicememo</${VOICE_TAG}>|g" "$TARGET_FILE"
else
    ui_print " > Adding Voice Recorder mode tag"
    sed -i "/<\/secfloatingfeature>/i $NEW_VOICE_LINE" "$TARGET_FILE"
fi

ui_print "--------------------------------------------------"
ui_print "Configuring system.prop properties..."
ui_print "--------------------------------------------------"

# ==================================================================
# SYSTEM PROPERTIES (system.prop)
# ==================================================================
SYS_PROP="$MODPATH/system.prop"
touch "$SYS_PROP"
set_perm 0 0 0644 "$SYS_PROP"

add_sys_prop() {
    local KEY="$1"
    local VAL="$2"
    
    if [ "$(getprop "$KEY")" != "$VAL" ]; then
        if ! grep -q "^${KEY}=" "$SYS_PROP"; then
            ui_print " > Setting prop: ${KEY}=${VAL}"
            echo "${KEY}=${VAL}" >> "$SYS_PROP"
        fi
    else
        ui_print " - Property ${KEY} is already set"
    fi
}

add_sys_prop "fw.max_users" "5"
add_sys_prop "fw.show_multiuserui" "1"
add_sys_prop "ro.surface_flinger.protected_contents" "true"

ui_print "**************************************************"
ui_print "      Installation Completed Successfully!        "
ui_print "**************************************************"
