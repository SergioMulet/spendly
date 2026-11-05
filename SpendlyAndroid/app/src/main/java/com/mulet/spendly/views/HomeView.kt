package com.mulet.spendly.views

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.SwipeToDismissBoxValue
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberSwipeToDismissBoxState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mulet.spendly.R
import com.mulet.spendly.models.Category
import com.mulet.spendly.models.ExpenseGroup
import com.mulet.spendly.viewmodels.HomeViewModel

@Composable
fun HomeView(
    modifier: Modifier = Modifier,
    viewModel: HomeViewModel = viewModel(factory = HomeViewModel.Factory),
) {
    val visibleMonth by viewModel.visibleMonth.collectAsStateWithLifecycle()
    val selectedDate by viewModel.selectedDate.collectAsStateWithLifecycle()
    val groups by viewModel.groups.collectAsStateWithLifecycle()
    val monthTotal by viewModel.monthTotal.collectAsStateWithLifecycle()
    val showingAddExpense by viewModel.showingAddExpense.collectAsStateWithLifecycle()
    val expenseToEdit by viewModel.expenseToEdit.collectAsStateWithLifecycle()
    val errorTitle by viewModel.errorTitle.collectAsStateWithLifecycle()
    val locale = LocalConfiguration.current.locales[0]
    var expandedCategories by rememberSaveable { mutableStateOf(emptySet<Category>()) }

    Box(modifier = modifier.fillMaxSize()) {
        LazyColumn(
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 88.dp),
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding(),
        ) {
            item {
                ExpenseCalendarView(viewModel = viewModel)
            }
            item {
                Text(
                    text = stringResource(
                        R.string.month_total,
                        viewModel.monthGrid(visibleMonth, locale).monthName,
                        viewModel.formatAmount(monthTotal, locale),
                    ),
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(vertical = 16.dp),
                )
            }
            if (groups.isEmpty()) {
                item {
                    Text(
                        text = stringResource(R.string.no_expenses),
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(vertical = 8.dp),
                    )
                }
            }
            groups.forEach { group ->
                val isExpanded = group.category in expandedCategories
                item(key = group.id) {
                    DeletableRow(onDelete = { viewModel.delete(group) }, resetSignal = errorTitle) {
                        ExpenseGroupHeader(
                            group = group,
                            total = viewModel.formatAmount(group.total, locale),
                            isExpanded = isExpanded,
                            onClick = {
                                expandedCategories = if (isExpanded) expandedCategories - group.category else expandedCategories + group.category
                            },
                        )
                    }
                }
                if (isExpanded) {
                    items(group.expenses, key = { it.id }) { expense ->
                        DeletableRow(onDelete = { viewModel.delete(expense) }, resetSignal = errorTitle) {
                            ListItem(
                                headlineContent = { Text(expense.title) },
                                supportingContent = { Text(viewModel.formatDay(expense.date, locale)) },
                                trailingContent = { Text(viewModel.formatAmount(expense.amount, locale)) },
                                modifier = Modifier
                                    .clickable { viewModel.expenseTapped(expense) }
                                    .padding(start = 16.dp),
                            )
                        }
                    }
                }
            }
        }
        FloatingActionButton(
            onClick = viewModel::addExpenseTapped,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp),
        ) {
            Icon(Icons.Filled.Add, contentDescription = stringResource(R.string.add_expense))
        }
    }

    if (showingAddExpense) {
        ExpenseView(expense = null, date = selectedDate, onClose = viewModel::expenseFormClosed)
    }
    expenseToEdit?.let { expense ->
        ExpenseView(expense = expense, date = expense.date, onClose = viewModel::expenseFormClosed)
    }
    errorTitle?.let { title ->
        AlertDialog(
            onDismissRequest = viewModel::errorDismissed,
            title = { Text(stringResource(title)) },
            confirmButton = { TextButton(onClick = viewModel::errorDismissed) { Text(stringResource(R.string.ok)) } },
        )
    }
}

/** The category row: its name, what was spent on it and an arrow that turns when it is open. */
@Composable
private fun ExpenseGroupHeader(group: ExpenseGroup, total: String, isExpanded: Boolean, onClick: () -> Unit) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 16.dp),
    ) {
        Text(
            text = stringResource(group.category.titleRes),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.weight(1f),
        )
        Text(text = total, style = MaterialTheme.typography.titleMedium)
        Icon(
            Icons.AutoMirrored.Filled.KeyboardArrowRight,
            contentDescription = null,
            modifier = Modifier.rotate(if (isExpanded) 90f else 0f),
        )
    }
    HorizontalDivider()
}

/** Swiping the row to the left deletes it. [resetSignal] brings the row back when the delete failed. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun DeletableRow(onDelete: () -> Unit, resetSignal: Any?, content: @Composable () -> Unit) {
    val state = rememberSwipeToDismissBoxState()
    LaunchedEffect(resetSignal) { state.reset() }

    SwipeToDismissBox(
        state = state,
        onDismiss = { if (it == SwipeToDismissBoxValue.EndToStart) onDelete() },
        enableDismissFromStartToEnd = false,
        backgroundContent = {
            Box(
                contentAlignment = Alignment.CenterEnd,
                modifier = Modifier
                    .fillMaxSize()
                    .background(MaterialTheme.colorScheme.error)
                    .padding(horizontal = 16.dp),
            ) {
                Icon(Icons.Filled.Delete, contentDescription = stringResource(R.string.delete), tint = MaterialTheme.colorScheme.onError)
            }
        },
    ) {
        Box(modifier = Modifier.background(MaterialTheme.colorScheme.surface)) {
            content()
        }
    }
}
