package com.mulet.spendly.views

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuAnchorType
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mulet.spendly.R
import com.mulet.spendly.models.Expense
import com.mulet.spendly.viewmodels.ExpenseViewModel
import java.time.LocalDate
import java.util.UUID

/** Adds an expense, or edits it when [expense] is given. [onClose] is called after saving and after cancelling. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExpenseView(expense: Expense?, date: LocalDate, onClose: () -> Unit) {
    // Each time the sheet opens it gets its own view model, so a cancelled form does not come back with its old text.
    val session = rememberSaveable { UUID.randomUUID().toString() }
    val viewModel: ExpenseViewModel = viewModel(key = session, factory = ExpenseViewModel.factory(expense, date))

    val title by viewModel.title.collectAsStateWithLifecycle()
    val amountText by viewModel.amountText.collectAsStateWithLifecycle()
    val selectedDate by viewModel.date.collectAsStateWithLifecycle()
    val category by viewModel.category.collectAsStateWithLifecycle()
    val canSave by viewModel.canSave.collectAsStateWithLifecycle()
    val didSave by viewModel.didSave.collectAsStateWithLifecycle()
    val showingError by viewModel.showingError.collectAsStateWithLifecycle()
    val locale = LocalConfiguration.current.locales[0]

    var categoryMenuExpanded by rememberSaveable { mutableStateOf(false) }
    var showingDatePicker by rememberSaveable { mutableStateOf(false) }

    LaunchedEffect(didSave) {
        if (didSave) onClose()
    }

    ModalBottomSheet(
        onDismissRequest = onClose,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
    ) {
        Column(
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier
                .padding(horizontal = 16.dp)
                .padding(bottom = 16.dp)
                .navigationBarsPadding()
                .imePadding(),
        ) {
            Text(stringResource(viewModel.screenTitle), style = MaterialTheme.typography.titleLarge)
            OutlinedTextField(
                value = title,
                onValueChange = viewModel::setTitle,
                label = { Text(stringResource(R.string.field_title)) },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
            )
            OutlinedTextField(
                value = amountText,
                onValueChange = viewModel::setAmountText,
                label = { Text(stringResource(R.string.field_amount)) },
                placeholder = { Text("0.00") },
                suffix = { Text(viewModel.currencySymbol) },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
            )
            ExposedDropdownMenuBox(expanded = categoryMenuExpanded, onExpandedChange = { categoryMenuExpanded = it }) {
                OutlinedTextField(
                    value = stringResource(category.titleRes),
                    onValueChange = {},
                    readOnly = true,
                    label = { Text(stringResource(R.string.field_category)) },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = categoryMenuExpanded) },
                    modifier = Modifier
                        .menuAnchor(ExposedDropdownMenuAnchorType.PrimaryNotEditable)
                        .fillMaxWidth(),
                )
                ExposedDropdownMenu(expanded = categoryMenuExpanded, onDismissRequest = { categoryMenuExpanded = false }) {
                    viewModel.categories.forEach { option ->
                        DropdownMenuItem(
                            text = { Text(stringResource(option.titleRes)) },
                            onClick = {
                                viewModel.setCategory(option)
                                categoryMenuExpanded = false
                            },
                        )
                    }
                }
            }
            OutlinedTextField(
                value = viewModel.formatDate(selectedDate, locale),
                onValueChange = {},
                readOnly = true,
                label = { Text(stringResource(R.string.field_date)) },
                trailingIcon = {
                    IconButton(onClick = { showingDatePicker = true }) {
                        Icon(Icons.Filled.DateRange, contentDescription = stringResource(R.string.field_date))
                    }
                },
                modifier = Modifier.fillMaxWidth(),
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.End), modifier = Modifier.fillMaxWidth()) {
                TextButton(onClick = onClose) { Text(stringResource(R.string.cancel)) }
                Button(onClick = viewModel::save, enabled = canSave) { Text(stringResource(R.string.save)) }
            }
        }
    }

    if (showingDatePicker) {
        val pickerState = rememberDatePickerState(initialSelectedDateMillis = viewModel.dateMillis)
        DatePickerDialog(
            onDismissRequest = { showingDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    viewModel.datePicked(pickerState.selectedDateMillis)
                    showingDatePicker = false
                }) { Text(stringResource(R.string.ok)) }
            },
            dismissButton = { TextButton(onClick = { showingDatePicker = false }) { Text(stringResource(R.string.cancel)) } },
        ) {
            DatePicker(state = pickerState)
        }
    }

    if (showingError) {
        AlertDialog(
            onDismissRequest = viewModel::errorDismissed,
            title = { Text(stringResource(R.string.error_save_expense)) },
            confirmButton = { TextButton(onClick = viewModel::errorDismissed) { Text(stringResource(R.string.ok)) } },
        )
    }
}
