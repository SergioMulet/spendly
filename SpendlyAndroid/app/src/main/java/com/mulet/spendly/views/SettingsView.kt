package com.mulet.spendly.views

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mulet.spendly.R
import com.mulet.spendly.viewmodels.SettingsViewModel

@Composable
fun SettingsView(
    modifier: Modifier = Modifier,
    viewModel: SettingsViewModel = viewModel(factory = SettingsViewModel.Factory),
) {
    val currency by viewModel.currency.collectAsStateWithLifecycle()
    val language by viewModel.language.collectAsStateWithLifecycle()

    Column(
        modifier = modifier
            .verticalScroll(rememberScrollState())
            .padding(vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp),
    ) {
        SettingsSection(stringResource(R.string.section_general)) {
            SettingsPicker(
                title = stringResource(R.string.currency),
                icon = Icons.Filled.Payments,
                color = Color(0xFFFF9500),
                options = viewModel.currencies,
                selection = currency,
                label = { stringResource(it.nameRes) },
                onSelect = viewModel::selectCurrency,
            )
            SettingsDivider()
            SettingsPicker(
                title = stringResource(R.string.language),
                icon = Icons.Filled.Language,
                color = Color(0xFF30B0C7),
                options = viewModel.languages,
                selection = language,
                label = { it.displayName },
                onSelect = viewModel::selectLanguage,
            )
        }

        SettingsSection(stringResource(R.string.section_data)) {
            SettingsRow(
                title = stringResource(R.string.export_data),
                icon = Icons.Filled.Download,
                color = Color(0xFF34C759),
                onClick = viewModel::exportData,
                trailingContent = {
                    Icon(
                        Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                },
            )
        }
    }
}
