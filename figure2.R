#-----------------------------------------------
# Figure 2: Grid plot for coefficient z-values
#-----------------------------------------------
# Create dataframe of t-values for combined model and all individual models
values <- data.frame(rbind(summary(all.countries.logit)$coefficients[, "z value"],
                           summary(original4.logit)$coefficients[, "z value"],
                           t(sapply(seq(country.models.logit), 
                                    FUN=function (x) summary(country.models.logit[[x]])$coefficients[, "z value"]))
))

# Clean up dataframe
# num.coefs <- length(attr(terms(form.ologit), "term.labels"))  # number of lhs coefficients
values <- values[, -1]  # Remove intercept; only include actual coefficients
values$country <- c("All countries", "Original four", levels(barometer$country.name))  # Add column with country names

# Build dataframe for plotting
plot.data <- melt(values, id="country")  # Convert to long
levels(plot.data$variable) <- nice.names  # Make coefficient names pretty
plot.data$p.value <- pnorm(abs(plot.data$value), lower.tail=FALSE) * 2  # Calculate p-values for t-values
plot.data$stars <- cut(plot.data$p.value, breaks=c(-Inf, 0.001, 0.01, 0.05, Inf), label=c("***", "**", "*", ""))  # Create column of significance labels
# plot.data$variable <- with(plot.data, reorder(variable, -abs(value)))  # Sort coefficients by value
# plot.data$country <- with(plot.data, reorder(country, -abs(value)))  # Sort countries by value
plot.data$variable <- factor(plot.data$variable, levels=levels(with(plot.data[plot.data$country=="All countries",], reorder(variable, -value))))  # Sort coefficients by value
plot.data$country <- factor(plot.data$country, levels=levels(with(plot.data[plot.data$variable==levels(plot.data$variable)[1],], reorder(country, -value))))  # Sort country by highest by most significant coefficient

# Force full models to the beginning
plot.data$country <- relevel(plot.data$country, ref="Original four")
plot.data$country <- relevel(plot.data$country, ref="All countries")

# Plot everything
p <- ggplot(aes(x=country, y=variable, fill=value), data=plot.data)
fig2 <- p + geom_tile() + scale_fill_gradient2(low="#D7191C", mid="white", high="#2C7BB6") + 
  #   geom_text(aes(label=stars, color=value), size=8) + scale_colour_gradient(low="grey30", high="white", guide="none") +
  geom_text(aes(label=stars), color="black", size=5) + 
  labs(y=NULL, x=NULL, fill="z-value") + geom_vline(xintercept=2.5, size=1.5, color="grey50") + 
  theme_bw() + theme(axis.text.x=element_text(angle = -45, hjust = 0))
fig2