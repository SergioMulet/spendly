package com.mulet.spendly.views

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.UnfoldMore
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp

/** Grouped card with a title above it, like an iOS `Section`. Rows are separated by dividers. */
@Composable
fun SettingsSection(title: String, content: @Composable () -> Unit) {
    Column(modifier = Modifier.padding(horizontal = 16.dp)) {
        Text(
            text = title.uppercase(),
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(start = 16.dp, bottom = 6.dp),
        )
        Surface(
            shape = RoundedCornerShape(16.dp),
            color = MaterialTheme.colorScheme.surfaceContainer,
        ) {
            Column { content() }
        }
    }
}

@Composable
fun SettingsDivider() {
    HorizontalDivider(modifier = Modifier.padding(start = 62.dp))
}

@Composable
fun SettingsRow(
    title: String,
    icon: ImageVector,
    color: Color,
    onClick: () -> Unit,
    trailingContent: @Composable (() -> Unit)? = null,
) {
    ListItem(
        modifier = Modifier.clickable(onClick = onClick),
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
        headlineContent = { Text(title) },
        leadingContent = { SettingsIcon(icon, color) },
        trailingContent = trailingContent,
    )
}

/** Row showing the current value; tapping it opens a menu with a check on the selected option. */
@Composable
fun <T> SettingsPicker(
    title: String,
    icon: ImageVector,
    color: Color,
    options: List<T>,
    selection: T,
    label: @Composable (T) -> String,
    onSelect: (T) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }

    SettingsRow(
        title = title,
        icon = icon,
        color = color,
        onClick = { expanded = true },
        trailingContent = {
            // The menu is anchored to the value, so it opens on the right, next to it.
            Box {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = label(selection),
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Icon(
                        Icons.Filled.UnfoldMore,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                DropdownMenu(
                    expanded = expanded,
                    onDismissRequest = { expanded = false },
                    shape = RoundedCornerShape(16.dp),
                ) {
                    options.forEach { option ->
                        DropdownMenuItem(
                            text = {
                                Text(
                                    text = label(option),
                                    style = if (option == selection) {
                                        MaterialTheme.typography.titleMedium
                                    } else {
                                        MaterialTheme.typography.bodyLarge
                                    },
                                )
                            },
                            trailingIcon = {
                                if (option == selection) Icon(Icons.Filled.Check, contentDescription = null)
                            },
                            onClick = {
                                onSelect(option)
                                expanded = false
                            },
                        )
                    }
                }
            }
        },
    )
}

@Composable
private fun SettingsIcon(icon: ImageVector, color: Color) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(30.dp)
            .clip(RoundedCornerShape(7.dp))
            .background(color),
    ) {
        Icon(icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
    }
}
